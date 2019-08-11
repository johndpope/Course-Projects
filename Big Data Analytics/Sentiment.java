import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.MapFunction;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Encoders;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.RowFactory;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.functions;
import org.apache.spark.sql.catalyst.encoders.ExpressionEncoder;
import org.apache.spark.sql.catalyst.encoders.RowEncoder;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructType;
import scala.Tuple2;
import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

public class Sentiment {
	public static void main(String[] args) throws FileNotFoundException {	
		String inputPath="/home/sarthak/Downloads/newsdata";
		String outputPath="/home/sarthak/Downloads/sentiment";
		String personPath="/home/sarthak/Downloads/entities.txt";
		String positivePath="/home/sarthak/Downloads/positive-words.txt";
		String negativePath="/home/sarthak/Downloads/negative-words.txt"; 
		
		StructType sentimentData = new StructType();
		sentimentData = sentimentData.add("source_name", DataTypes.StringType, false);
		sentimentData = sentimentData.add("year_month", DataTypes.StringType, false); 
		sentimentData = sentimentData.add("entity", DataTypes.StringType, false);
		sentimentData = sentimentData.add("sentiment", DataTypes.IntegerType, false);
	    ExpressionEncoder<Row> dateRowEncoder = RowEncoder.apply(sentimentData);
				
		SparkSession sparkSession = SparkSession.builder()
				.appName("Sentiment Analysis")		//Name of application
				.master("local")								//Run the application on local node
				.config("spark.sql.shuffle.partitions","2")		//Number of partitions
				.getOrCreate();
		
		Dataset<Row> inputDataset=sparkSession.read().option("multiLine", true).json(inputPath);
		Scanner persons = new Scanner(new File(personPath));
		Set<String> personSet = new HashSet<>();
		while (persons.hasNext()) {
		    personSet.add(persons.next().trim());
		}
		persons.close();
		Scanner positive = new Scanner(new File(positivePath));
		Set<String> positiveSet = new HashSet<>();
		while (positive.hasNext()) {
			positiveSet.add(positive.next().trim());
		}
		positive.close();
		Scanner negative = new Scanner(new File(negativePath));
		Set<String> negativeSet = new HashSet<>();
		while (negative.hasNext()) {
			negativeSet.add(negative.next().trim());
		}
		negative.close();

		Dataset<Row> sourceword=inputDataset.flatMap(new FlatMapFunction<Row,Row>(){
			public Iterator<Row> call(Row row) throws Exception {
				String source=((String)row.getAs("source_name"));
				String yearmonth=((String)row.getAs("date_published")).substring(0, 7);

				String allwords=(String)row.getAs("article_body");
			    allwords = allwords.toLowerCase().replaceAll("[^A-Za-z]", " ");  //Remove all punctuation and convert to lower case
			    allwords = allwords.replaceAll("( )+", " ");   //Remove all double spaces
			    allwords = allwords.trim(); 
			    List<String> wordList = Arrays.asList(allwords.split(" ")); //Get words
			    List<String> wordList2= new ArrayList<String>();
			    
			    List<Row> sentimentList = new ArrayList<>();
			    int sz = wordList.size(), first=0, last=0;
			    for(int i=0; i<sz; i++)
			    {
			    	String entity = wordList.get(i);
			    	if( personSet.contains(entity) )
			    	{
			    		first = i-5;
			    		if(first<5) first=0;
			    		last = i+5;
			    		if(last>=sz-1) last = sz-1;
			    		
			    		int sentiNearby = 0;
			    		for(int j=first; j<=last; j++)
			    		{
			    			String sentiWord = wordList.get(j);
			    			if (positiveSet.contains(sentiWord))
			    			{
			    				Row appendRow=RowFactory.create(source, yearmonth, entity, 1);
			    				sentimentList.add(appendRow);
			    				sentiNearby = 1;
			    			}
			    			else if (negativeSet.contains(sentiWord))
			    			{
			    				Row appendRow=RowFactory.create(source, yearmonth, entity, -1);
			    				sentimentList.add(appendRow);
			    				sentiNearby = 1;
			    			}
			    		}
			    		if(sentiNearby==0)
			    		{
			    			Row appendRow=RowFactory.create(source, yearmonth, entity, 0);
		    				sentimentList.add(appendRow);
			    		}
			    	}
			    }
			    return sentimentList.iterator();
			   }	    					
		}, dateRowEncoder);
		
		Dataset<Row> sentiCount=sourceword.groupBy("source_name", "year_month", "entity", "sentiment").count().as("count");
		sentiCount = sentiCount.withColumn("product", sentiCount.col("count").multiply(sentiCount.col("sentiment")));
		sentiCount = sentiCount.groupBy("source_name", "year_month", "entity").agg(functions.sum("product").alias("overallsenti"), 
				functions.sum("count").alias("totalsenti"));
		sentiCount = sentiCount.filter("totalsenti >= 5");
		sentiCount = sentiCount.drop("totalsenti");
		sentiCount = sentiCount.withColumn("absol", functions.abs(sentiCount.col("overallsenti")));
		sentiCount = sentiCount.orderBy(sentiCount.col("absol").desc()).drop("absol");
		sentiCount.toJavaRDD().saveAsTextFile(outputPath);	
	}	
}
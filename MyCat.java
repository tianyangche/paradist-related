package org.myorg;
import java.io.IOException;
import java.net.URI;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.io.IOUtils;

public class MyCat {
	public static void main(String[] args) throws Exception {
		String uri = args[0];
		String tempIoRatio = args[1];
		float targetRatio = Float.parseFloat(tempIoRatio);
		Configuration conf = new Configuration();
		FileSystem fs = FileSystem.get(URI.create(uri),conf);
		FSDataInputStream in = null;
		try {
			Path p = new Path(uri);
			long len = fs.getLength(p);
//			System.out.println(len);
			in = fs.open(new Path(uri));
			byte[] buffer = new byte[1024*1024];
		    long beginTime = System.currentTimeMillis();
			long ioTime = 0;
			long totalTime = 0;
			while( len > 0 ) {
				long ioBeginTime = System.currentTimeMillis();
				int alreadyRead = in.read(buffer,0,1024*1024);
				long ioEndTime = System.currentTimeMillis();
				ioTime = ioTime + ioEndTime-ioBeginTime;
				totalTime = ioEndTime - beginTime;
				
				int toSleep =(int) (ioTime/targetRatio - (float)totalTime);
				if(toSleep > 0) {
					Thread.sleep(toSleep);
				}

				len -= alreadyRead;
			}
			System.out.println("I/O time is : "+ioTime);
			System.out.println("Total time is : " + totalTime);
		} finally {
			System.out.println("It works");
			IOUtils.closeStream(in);
		}

	
	
	}


}

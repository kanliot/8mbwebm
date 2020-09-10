# 8mbwebm
##### This is the easiest command line ffmpeg wrapper.
**Usage:**    
`8mbwebm video.mp4`

kind of simple isn't it? 

If you don't want the default output, you can change the output size, the codec, pixel size, etc.    
You can also clip segments from the source video.    
The main use case is if you want a video shrunk down, and all you know is the size in megabytes of the output file.

##### Main Options
 *  Fast mode with -f
 *  New size in megabytes with -m
 *  H.264 mode with -2
 *  New size in pixels with -s
 *   Clip from time #1 to time #2 with -ss and -to
    

    8mbwebm [options] inputfile...

     Options:
       -h, -help            brief help message
       -p			set prefix. "8MB_" is the default.
       -ss 			start time
       -to 			end time
       -s			new size like: 640x480 (WIDTHxHEIGHT)
        			    if you like, you can omit one of the 
        			    dimensions, like -s 640x or -s x480 
       -m 			change size in megabytes for output file
       -f 			go fast. ( -fast selects x264 )
       -264, -2 		output in mp4 (aac + H.264) 
      			     ( libx264 + libfdk_aac in ffmpeg) 
       -d 			specify output directory instead of dir of file
       -mono		downmix to output mono.
       -get-fps 		print FPS and exit
       -lower-fps 		reduce FPS by a ratio like 3:2
         			e.g. to reduce 25%, use: -lower-fps '4:3' 
    default -codec is opus + vp9  ( libvpx-vp9, libopus in ffmpeg) `

**8mbwebm** is a single script with no 'dependencies'.  Should work on BSD, Linux and OSX when [ffmpeg](https://repology.org/project/ffmpeg/versions) and [mediainfo](https://repology.org/project/mediainfo/versions) are installed.

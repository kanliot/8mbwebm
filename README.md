# 8mbwebm
##### This is the easiest command line ffmpeg wrapper.
**Usage:**    
`8mbwebm video.mp4`

kind of simple isn't it? 

If you don't want the default output, you can change the output size, the codec, pixel size, etc.    
You can also clip segments from the source video.    
The main use case is if you want a video shrunk down, and all you know is the size in megabytes of the output file.

**December 2020**    
I've added a redo mode.  really, 8mbwebm was producing outsized files about 20% of the time.  It currently calculates bitrate as a percent %, but perhaps it should just subtract 600K from the target size, and use that bitrate as a percent.    
Anyhow, the redo mode is easy to use.  This program asks you if you want to redo,just enter "y". 

I've also decided that my future work on this is to get rid of VP9, and try and make it transparent to systems without lib_fdk and mediainfo installed.   x265 support makes much more sense, and it seems a little bit faster on my system.   Check back in 2-3 months!... it's just that it seems like x265 isn't supported in discord, or on many web platforms, but VP9 is.  Need more info!

##### Main Options
 *  Fast mode with -f
 *  New size in megabytes with -m
 *  .mp4 (H.264) mode with -2
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
       -get-duration        print duration in SSSS.ms for each video and exit
    default -codec is opus + vp9  ( libvpx-vp9, libopus in ffmpeg) `

**8mbwebm** is a single script with no 'dependencies'.  Should work on BSD, Linux and OSX when [ffmpeg](https://repology.org/project/ffmpeg/versions) and [mediainfo](https://repology.org/project/mediainfo/versions) are installed.

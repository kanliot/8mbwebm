# 8mbwebm
##### This is the easiest command line ffmpeg wrapper.
**Usage:**    
`8mbwebm video.mp4`

kind of simple isn't it? 

If you don't want the default output, you can change the output size, the codec, pixel size, etc.    
You can also clip segments from the source video.    
The main use case is if you want a video shrunk down, and all you know is the size in megabytes of the output file.


    8mbwebm [options] inputfile...

     Options:
       -h, -help            brief help message
       -p			set prefix. "8MB_" is the default.
       -ss 			start time
       -to 			end time
       -s			new size like: 640x480
       -m 			change size in megabytes for output file
       -264, -2 		output in mp4 (aac + H.264) 
      			     ( libx264 + libfdk_aac in ffmpeg) 
       -d 			specify output directory instead of dir of file
    default -codec is opus + vp9  ( libvpx-vp9, libopus in ffmpeg) `

**8mbwebm** requires perl.  Should work on \*nix and OSX when ffmpeg and mediainfo are installed.

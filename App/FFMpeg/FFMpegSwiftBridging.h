//
//  FFMpegSwiftBridge.h
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

#ifndef FFMpegSwiftBridge_h
#define FFMpegSwiftBridge_h

#include <stdio.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswresample/swresample.h>
#import <libavutil/avutil.h>
#import <libavutil/pixdesc.h>

int averror_ENOMEM(void);
int averror_EINVAL(void);
int averror_EAGAIN(void);

int averror_EOF(void);
int averror_DECODER_NOT_FOUND(void);
int averror_STREAM_NOT_FOUND(void);

#endif /* FFMpegSwiftBridge_h */

//
//  FFMpegSwiftBridge.c
//  SauronPlayer
//
//  Created by sauron on 2023/8/1.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

#include "FFMpegSwiftBridging.h"
#include <libavutil/error.h>

int averror_ENOMEM(void)
{
    return AVERROR(ENOMEM);
}

int averror_EINVAL(void)
{
    return AVERROR(EINVAL);
}

int averror_EAGAIN(void)
{
    return AVERROR(EAGAIN);
}

int averror_EOF(void)
{
    return AVERROR_EOF;
}

int averror_DECODER_NOT_FOUND(void)
{
    return AVERROR_DECODER_NOT_FOUND;
}

int averror_STREAM_NOT_FOUND(void)
{
    return AVERROR_STREAM_NOT_FOUND;
}




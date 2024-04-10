//
//  FFMpeg+Extension.swift
//  SauronPlayer
//
//  Created by sauron on 2023/8/10.
//  Copyright © 2023 com.sauronpi. All rights reserved.
//

import Foundation
extension AVMediaType: CustomStringConvertible {
    public var description: String {
        switch self {
        case AVMEDIA_TYPE_UNKNOWN:      return "AVMEDIA_TYPE_UNKNOWN"
        case AVMEDIA_TYPE_VIDEO:        return "AVMEDIA_TYPE_VIDEO"
        case AVMEDIA_TYPE_AUDIO:        return "AVMEDIA_TYPE_AUDIO"
        case AVMEDIA_TYPE_DATA:         return "AVMEDIA_TYPE_DATA"
        case AVMEDIA_TYPE_SUBTITLE:     return "AVMEDIA_TYPE_SUBTITLE"
        case AVMEDIA_TYPE_ATTACHMENT:   return "AVMEDIA_TYPE_ATTACHMENT"
        case AVMEDIA_TYPE_NB:           return "AVMEDIA_TYPE_NB"
        default:                        return "UNKNOWN"
        }
    }
}

extension AVPixelFormat: CustomStringConvertible {
    public var description: String {
        if let cString = av_get_pix_fmt_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVSampleFormat: CustomStringConvertible {
    public var description: String {
        if let cString = av_get_sample_fmt_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVRational: CustomStringConvertible {
    public var description: String { "\(num)/\(den)" }
}

extension AVCodecParameters: CustomStringConvertible {
    public var description: String { String(describing: self) }
}

extension AVCodecID: CustomStringConvertible {
    public var description: String { String(cString: avcodec_get_name(self)!) }
}

extension AVChromaLocation: CustomStringConvertible {
    public var description: String {
        if let cString = av_chroma_location_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVColorSpace: CustomStringConvertible {
    public var description: String {
        if let cString = av_color_space_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVColorPrimaries: CustomStringConvertible {
    public var description: String {
        if let cString = av_color_primaries_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVColorRange: CustomStringConvertible {
    public var description: String {
        if let cString = av_color_range_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVColorTransferCharacteristic: CustomStringConvertible {
    public var description: String {
        if let cString = av_color_transfer_name(self) {
            return String(cString: cString)
        } else {
            return "Unknown"
        }
    }
}

extension AVDiscard: CustomStringConvertible {
    public var description: String {
        switch self {
        case AVDISCARD_NONE:        return "AVDISCARD_NONE"
        case AVDISCARD_DEFAULT:     return "AVDISCARD_DEFAULT"
        case AVDISCARD_NONREF:      return "AVDISCARD_NONREF"
        case AVDISCARD_BIDIR:       return "AVDISCARD_BIDIR"
        case AVDISCARD_NONINTRA:    return "AVDISCARD_NONINTRA"
        case AVDISCARD_NONKEY:      return "AVDISCARD_NONKEY"
        case AVDISCARD_ALL:         return "AVDISCARD_ALL"
        default:                    return "UNKNOWN"
        }
    }
}

extension AVPictureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case AV_PICTURE_TYPE_NONE:      return "AV_PICTURE_TYPE_NONE"
        case AV_PICTURE_TYPE_I:         return "AV_PICTURE_TYPE_I"
        case AV_PICTURE_TYPE_P:         return "AV_PICTURE_TYPE_P"
        case AV_PICTURE_TYPE_B:         return "AV_PICTURE_TYPE_B"
        case AV_PICTURE_TYPE_S:         return "AV_PICTURE_TYPE_S"
        case AV_PICTURE_TYPE_SI:        return "AV_PICTURE_TYPE_SI"
        case AV_PICTURE_TYPE_SP:        return "AV_PICTURE_TYPE_SP"
        case AV_PICTURE_TYPE_BI:        return "AV_PICTURE_TYPE_BI"
        default:                        return "UNKNOWN"
        }
    }
}

extension AVChannelOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case AV_CHANNEL_ORDER_UNSPEC:           return "AV_CHANNEL_ORDER_UNSPEC"
        case AV_CHANNEL_ORDER_NATIVE:           return "AV_CHANNEL_ORDER_NATIVE"
        case AV_CHANNEL_ORDER_CUSTOM:           return "AV_CHANNEL_ORDER_CUSTOM"
        case AV_CHANNEL_ORDER_AMBISONIC:        return "AV_CHANNEL_ORDER_AMBISONIC"
        default:                                return "UNKNOWN"
        }
    }
}

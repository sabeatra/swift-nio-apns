//===----------------------------------------------------------------------===//
//
// This source file is part of the NIOApns open source project
//
// Copyright (c) 2019 the NIOApns project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of NIOApns project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIO
import NIOFoundationCompat
import Foundation

/// This is a class created the handles our stream.
/// It checks for a good request to APNS Servers.
final class APNSStreamHandler: ChannelDuplexHandler {
    typealias InboundIn = APNSResponse
    typealias OutboundOut = ByteBuffer
    typealias OutboundIn = APNSRequestContext

    var queue: [APNSRequestContext]

    init() {
        queue = []
    }

    func channelRead(context _: ChannelHandlerContext, data: NIOAny) {
        let res = unwrapInboundIn(data)
        guard let current = self.queue.popLast() else { return }
        guard res.header.status == .ok else {
            if var buffer = res.byteBuffer, let data = buffer.readData(length: buffer.readableBytes), let error = try? JSONDecoder().decode(APNSError.ResponseStruct.self, from: data) {
                current.responsePromise.fail(APNSError.ResponseError.badRequest(error.reason))
            }
            return
        }
        current.responsePromise.succeed(Void())
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let input = unwrapOutboundIn(data)
        queue.insert(input, at: 0)
        context.write(wrapOutboundOut(input.request), promise: promise)
    }
}

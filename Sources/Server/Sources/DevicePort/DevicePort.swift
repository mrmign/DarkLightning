/**
 *
 * 	DarkLightning
 *
 *
 *
 *	The MIT License (MIT)
 *
 *	Copyright (c) 2017 Jens Meder
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy of
 *	this software and associated documentation files (the "Software"), to deal in
 *	the Software without restriction, including without limitation the rights to
 *	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 *	the Software, and to permit persons to whom the Software is furnished to do so,
 *	subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in all
 *	copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *	FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *	COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *	IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import CoreFoundation

public final class DevicePort: WriteStreamWrap {
	
	// MARK: Constants
	
	private static let DefaultPort: UInt16 = 2347
	
	// MARK: Init
	
	public convenience init() {
		self.init(
			delegate: DevicePortDelegateFake()
		)
	}
	
	public convenience init(delegate: DevicePortDelegate) {
		self.init(
			port: DevicePort.DefaultPort,
			delegate: delegate
		)
	}
	
	public convenience init(port: UInt16, delegate: DevicePortDelegate) {
		let connections = InsertConnectionReaction(
			origin: SocketConnections(
				queue: DispatchQueue.global(qos: .background),
				readReaction: StreamDelegates(
					delegates: [
                        ReadStreamReaction(delegate: delegate),
						CloseStreamReaction(),
						DisconnectStreamReaction(delegate: delegate)
					]
				),
				writeReaction: CloseStreamReaction(),
				connections: [:]
			),
			delegate: delegate
		)
		self.init(
			port: port,
			queue: DispatchQueue.global(qos: .background),
			connections: connections,
			socket: Memory<CFSocketNativeHandle>(initialValue: -1)
		)
	}
	
	public required init(port: UInt16, queue: DispatchQueue, connections: Connections, socket: Memory<CFSocketNativeHandle>) {
		super.init(
			origin: OpeningDevicePort(
				origin: ClosingDevicePort(
					origin: WritingDevicePort(
						origin: WriteStreamFake(),
						connections: connections
					),
					socket: socket,
					connections: connections
				),
				port: port,
				queue: queue,
				connections: connections,
				socket: socket
			)
		)
    }
}
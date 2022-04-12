//
//  NetworkMonitor.swift
//  SLPProject
//
//  Created by 노건호 on 2022/01/27.
//

import Foundation
import Network
import RxRelay

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor = NWPathMonitor()
    let connectionState = BehaviorRelay<Bool>(value: false)
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType:ConnectionType = .unknown
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    public func startMonitoring() {
        // 지속적으로 모니터링
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in

            self?.isConnected = path.status == .satisfied
            self?.connectionType(path)
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    
    private func connectionType(_ path: NWPath) {

        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
            print("wifi에 연결")

        }else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("cellular에 연결")

        }else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("wiredEthernet에 연결")

        }else {
            connectionType = .unknown
            print("unknown ..")
        }
    }
}

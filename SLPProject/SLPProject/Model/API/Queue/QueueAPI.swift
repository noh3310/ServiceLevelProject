//
//  QueueAPI.swift
//  SLPProject
//
//  Created by 노건호 on 2022/02/07.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import RxRelay

private enum QueueEnum: Int {
    case noConnectinon = 0   // enum 처리
    case success = 200
    case moreThreeReportUser = 201
    case penaltyGradeOne = 203
    case penaltyGradeTwo = 204
    case penaltyGradeThree = 205
    case noGenderSelect = 206
    case firebaseTokenError = 401
    case noRegisterUser = 406
    case serverError = 500
    case clientError = 501
}

private enum QueueURL: String {
    case queue = "queue"
    case onqueue = "queue/onqueue"
}

extension QueueURL {
    var url: URL {
        URL(string: BaseAPI.baseURL + self.rawValue)!
    }
}

class QueueAPI {
    
    // API상태 업데이트
    let state = PublishRelay<QueueAPIResult>()

    private var disposeBag = DisposeBag()
    
    // 기본 코드
    fileprivate func baseQueueAPIRequest(method: HTTPMethod, url: URL, parameters: Parameters?, header: HTTPHeaders, completion: @escaping (Data?, QueueEnum) -> Void) {
        if NetworkMonitor.shared.isConnected {
            RxAlamofire.requestData(method, url, parameters: parameters, headers: header)
                .debug()
                .subscribe { (header, data) in
                    // APIState를 Enum으로 변경
                    let apiState = QueueEnum(rawValue: header.statusCode)!
                    
                    completion(data, apiState)
                }
                .disposed(by: disposeBag)
        } else {
            completion(nil, .noConnectinon)
        }

    }
    
    func queue() {
        var parameters: Parameters {
            [
                "type": 2,
                "region": region(MainModel.shared.currentPosition.value[0], MainModel.shared.currentPosition.value[1]),
                "long": MainModel.shared.currentPosition.value[1],
                "lat": MainModel.shared.currentPosition.value[0],
                "hf": MainModel.shared.myHobby.value
            ]
        }
            
        
        baseQueueAPIRequest(method: .post, url: QueueURL.queue.url, parameters: parameters, header: BaseAPI.header) { [self] (data, apiState) in
            print("apiState = ", apiState.rawValue)
            switch apiState {
            case .noConnectinon:
                break
            case .success:
                state.accept(.success)
            case .moreThreeReportUser:
                state.accept(.moreThreeReportUser)
            case .penaltyGradeOne:
                state.accept(.penaltyGradeOne)
            case .penaltyGradeTwo:
                state.accept(.penaltyGradeTwo)
            case .penaltyGradeThree:
                state.accept(.penaltyGradeThree)
            case .noGenderSelect:
                state.accept(.noGenderSelect)
            case .firebaseTokenError:
                FirebaseToken.shared.updateIDToken {
                    queue()
                }
            case .noRegisterUser:
                state.accept(.noRegisterUser)
            case .serverError:
                state.accept(.serverError)
            case .clientError:
                state.accept(.clientError)
            }
        }
    }
    
    private func region(_ lat: Double, _ long: Double) -> Int {
        let latString = String(lat + 90).replacingOccurrences(of: ".", with: "")
        let endIndex = latString.index(latString.startIndex, offsetBy: 5)
        let latValue = latString[..<endIndex]
        
        let longString = String(long + 180).replacingOccurrences(of: ".", with: "")
        let longEndIndex = longString.index(longString.startIndex, offsetBy: 5)
        let longValue = longString[..<longEndIndex]
        
        print("regions = ", Int(latValue + longValue)!)
        return Int(latValue + longValue)!
    }
    
    func onQueue() {
        var parameters: Parameters {
            [
                "region": region(MainModel.shared.currentPosition.value[0], MainModel.shared.currentPosition.value[1]),
                "lat": MainModel.shared.currentPosition.value[0],
                "long": MainModel.shared.currentPosition.value[1]
            ]
        }
        
        baseQueueAPIRequest(method: .post, url: QueueURL.onqueue.url, parameters: parameters, header: BaseAPI.header) { [self] (data, apiState) in
            switch apiState {
            case .noConnectinon:
                state.accept(.noConnectinon)
            case .success:
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    let decodeData = try decoder.decode(FriendsData.self, from: data)
                    print(decodeData)
                    // 모델에 값 변경해줌
                    MainModel.shared.nearFriends.accept(decodeData.fromQueueDB)
                    MainModel.shared.requestNearFriends.accept(decodeData.fromQueueDBRequested)
                    MainModel.shared.fromRecomend.accept(decodeData.fromRecommend)
                    
                    // 그리고 구독하라고 설정
                    state.accept(.success)
                } catch {
                    print("decode error")
                }
                state.accept(.success)
            case .firebaseTokenError:
//                state.accept(.firebaseTokenError)
                FirebaseToken.shared.updateIDToken {
                    onQueue()
                }
            case .noRegisterUser:
                state.accept(.noRegisterUser)
            case .serverError:
                state.accept(.serverError)
            case .clientError:
                state.accept(.clientError)
            default:
                break
            }
        }
    }
    
}

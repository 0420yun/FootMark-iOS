//
//  KeychainManager.swift
//  FootMark
//
//  Created by 윤성은 on 6/14/24.
//

import Foundation
import Moya
import KeychainSwift

class KeychainManager {
    static let shared = KeychainManager()
    private let keychain = KeychainSwift()
    
    private init() {}
    
    func setAccessToken(_ token: String) {
        keychain.set("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIwNDIweXVuQGdtYWlsLmNvbSIsImF1dGgiOiJST0xFX1VTRVIiLCJpYXQiOjE3MTg1MTk2ODUsImV4cCI6MTcxODUyMzI4NX0.bDWmMV0LCVwhX2PDu2CDuZtKMNWArOiNwOjLzKrs_jsdwnbf16f893RiwOuNJhRp2ImQFAn6kKQJxn5i9eJAUw", forKey: "accessToken")
    }
    
    func getAccessToken() -> String? {
        return keychain.get("accessToken")
    }
    
    func removeAccessToken() {
        keychain.delete("accessToken")
    }
    
    // Moya 요청 클로저를 생성하는 메서드
        func createRequestClosure() -> MoyaProvider<CategoryTargetType>.RequestClosure {
            return { (endpoint: Endpoint, done: @escaping MoyaProvider.RequestResultClosure) in
                do {
                    var request = try endpoint.urlRequest()
                    if let accessToken = self.getAccessToken() {
                        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    } else {
                        request.addValue("accessToken 없음", forHTTPHeaderField: "Authorization")
                    }
                    done(.success(request))
                } catch {
                    done(.failure(MoyaError.underlying(error, nil)))
                }
            }
        }
}
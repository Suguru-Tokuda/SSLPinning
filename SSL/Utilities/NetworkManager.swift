//
//  SSLPinningManager.swift
//  SSL
//
//  Created by Suguru Tokuda on 12/1/23.
//

import Foundation

class NetworkManager {
    var isCertificatePinning = false
    var hardcodedPublicKey = ""
    
    private let urlSession: URLSession
    
    init(pinning: Bool = true) {
        urlSession = URLSession(configuration: .default, delegate: pinning ? URLSessionDelegateHandler() : nil, delegateQueue: nil)
    }
    
    func makeRequest(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.urlSession.dataTask(with: URLRequest(url: url)) { [weak self] _, _, _ in
        }
        .resume()
    }
}

final class URLSessionDelegateHandler: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // check for certificates count in serverTrust if it's > 0 then only proceed
        guard let trust = challenge.protectionSpace.serverTrust,
              SecTrustGetCertificateCount(trust) > 0 else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Get the certificates from SecTrustCopyCertificateChain and extract first certificate
        guard let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let certificate = certificates.first else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Convert certificate to Data
        let data = SecCertificateCopyData(certificate) as Data
        
        // Check if our certificate list contains data
        if pinnedCertificates().contains(data) {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        } else {
            // Cancel the Authentication Challenge
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
    }
    
    private func pinnedCertificates() -> [Data] {
        var retVal: [Data] = []
        
        if let url = Bundle.main.url(forResource: Constants.certificationFileName, withExtension: Constants.certificationFileType) {
            do {
                let pinnedCertificateData = try Data(contentsOf: url)
                retVal.append(pinnedCertificateData)
            } catch {
                fatalError()
            }
        }
        
        return retVal
    }
    
    private func pinnedKeys() -> [SecKey] {
        var retVal: [SecKey] = []
        
        if let url = Bundle.main.url(forResource: "", withExtension: "") {
            do {
                let pinnedCertificateData = try Data(contentsOf: url) as CFData
                
                if let pinnedCertificate = SecCertificateCreateWithData(nil, pinnedCertificateData),
                   let key = publicKey(for: pinnedCertificate) {
                    retVal.append(key)
                }
            } catch {
                
            }
        }
        
        return retVal
    }
    
    private func publicKey(for certificate: SecCertificate) -> SecKey? {
        var retVal: SecKey?
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)
        
        if let trust = trust, trustCreationStatus == errSecSuccess {
            retVal = SecTrustCopyKey(trust)
        }
        
        return retVal
    }
}

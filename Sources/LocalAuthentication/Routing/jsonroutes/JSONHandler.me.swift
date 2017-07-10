//
//  JSONHandler.me.swift
//  LocalAuthentication
//
//  Created by Jonathan Guthrie on 2017-07-10.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionMySQL


extension LocalAuthJSONHandlers {

	// GET request for current user info
	public static func me(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			if let i = request.session?.userid, !i.isEmpty {
				let acc = Account()
				do {
					try acc.get(i)
					_ = try? response.setBody(json: [
						"userid":acc.id,
						"username":acc.username,
						"email":acc.email,
						"usertype":"\(acc.usertype)"
						])
					response.completed()
					return
				} catch {
					LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
					return
				}
			} else {
				LocalAuthHandlers.error(request, response, error: "NotLoggedIn", code: .badRequest)
				return
			}
		}
	}

	// POST request for current user change password
	public static func changePassword(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			if let i = request.session?.userid, !i.isEmpty {
				let acc = Account()
				do {
					try acc.get(i)

					// start chpwd
					if let postBody = request.postBodyString, !postBody.isEmpty {
						do {
							let postBodyJSON = try postBody.jsonDecode() as? [String: String] ?? [String: String]()
							if let password = postBodyJSON["password"], !password.isEmpty {
								acc.makePassword(password)
								try acc.save()
								_ = try response.setBody(json: ["error": "none", "msg":"Your password has been changed."])
								response.completed()
								return
							} else {
								LocalAuthHandlers.error(request, response, error: "Please supply a vaid password", code: .badRequest)
								return
							}
						} catch {
							LocalAuthHandlers.error(request, response, error: "Invalid JSON", code: .badRequest)
							return
						}
					} else {
						LocalAuthHandlers.error(request, response, error: "Change Password Error: Insufficient Data", code: .badRequest)
						return
					}
					// end chpwd
				} catch {
					LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
					return
				}
			} else {
				LocalAuthHandlers.error(request, response, error: "NotLoggedIn", code: .badRequest)
				return
			}
		}
	}

}


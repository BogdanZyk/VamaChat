//
//  AppError.swift
//  Vama
//
//  Created by Bogdan Zykov on 04.08.2023.
//


import Foundation

enum AppError {
    case network(type: Enums.NetworkError)
    case auth(type: Enums.AuthenticationError)
    case file(type: Enums.FileError)
    case custom(errorDescription: String?)

    class Enums { }
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .network(let type): return type.localizedDescription
        case .file(let type): return type.localizedDescription
        case .custom(let errorDescription): return errorDescription
        case .auth(type: let type): return type.localizedDescription
        }
    }
}

// MARK: - Network Errors

extension AppError.Enums {
    enum NetworkError {
        case parsing
        case notFound
        case custom(errorCode: Int?, errorDescription: String?)
    }
}

extension AppError.Enums.NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .parsing: return "Parsing error"
            case .notFound: return "URL Not Found"
            case .custom(_, let errorDescription): return errorDescription
        }
    }

    var errorCode: Int? {
        switch self {
            case .parsing: return nil
            case .notFound: return 404
            case .custom(let errorCode, _): return errorCode
        }
    }
}

extension AppError.Enums{
    enum AuthenticationError{
        case noSetCurrentUser
    }
}
extension AppError.Enums.AuthenticationError: LocalizedError{
    var errorDescription: String? {
        switch self {
        case .noSetCurrentUser: return "No set current user"
        }
    }
}

// MARK: - File Errors

extension AppError.Enums {
    enum FileError {
        case read(path: String)
        case write(path: String, value: Any)
        case custom(errorDescription: String?)
    }
}

extension AppError.Enums.FileError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .read(let path): return "Could not read file from \"\(path)\""
            case .write(let path, let value): return "Could not write value \"\(value)\" file from \"\(path)\""
            case .custom(let errorDescription): return errorDescription
        }
    }
}

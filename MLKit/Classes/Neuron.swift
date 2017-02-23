//
//  Neuron.swift
//  Pods
//
//  Created by Guled  on 2/23/17.
//
//

import Foundation
import Upsurge


open class Neuron {

    fileprivate var _weightsComingIn:ValueArray<Float>!
    fileprivate var _weightsGoingOut:ValueArray<Float>!

    var weightsComingIn:ValueArray<Float> { // List of input weights


        get {
            return _weightsComingIn
        }


        set {
            return _weightsComingIn = newValue
        }
    }

    var weightsGoingOut:ValueArray<Float> { // List of output weights

        get {
            return _weightsGoingOut
        }

        set {
            return _weightsGoingOut = newValue
        }

    }

    open func initializeNueron() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }
    

}





//
//  Training.swift
//  Pods
//
//  Created by Guled  on 2/23/17.
//
//

import Foundation
import Upsurge


public protocol Training {

}

extension Training {


    /**
     The train method trains your Neural Network object. WARNING: Use this method only for Perceptron and Adaline architectures. 
     The Backpropagation class has it's own train method. 

     - parameter fncType: ActivationFunctionType enum case
     - parameter value: A Float

     - returns: A Float
     */
    public mutating func train(network: NeuralNet) -> NeuralNet {

        var weightsComingIn: ValueArray<Float>! = ValueArray<Float>()

        var rows = network.trainingSet.rows
        var columns = network.trainingSet.columns


        var epochs: Int = 0
        var error: Float = 0.0
        var meanSquaredError: Float = 0.0

        while epochs < network.maxEpochs {

            var estimatedOutput: Float!
            var actualOutput: Float!

            for var i in 0..<rows {

                var netValue: Float = 0

                for var j in 0..<columns {
                    weightsComingIn = network.inputLayer.listOfNeurons[j].weightsComingIn
                    var inputWeight = weightsComingIn[0]
                    netValue += inputWeight * network.trainingSet[i, j]
                }


                // Estimate the error of our model
                estimatedOutput = try! self.activationFunc(fncType: network.activationFuncType, value: netValue)
                actualOutput = network.targetOutputSet[i]

                error = actualOutput - estimatedOutput

                // Weight adjustment if error is not satisfactory
                if abs(error) > network.targetError {

                    var inputLayer = InputLayer()
                    inputLayer.listOfNeurons = teachNeuronOfLayer(numberOfInputNeurons: columns, line: i, network: network, netValue: netValue, error: error)

                    network.inputLayer = inputLayer
                }

            }

            meanSquaredError = powf(actualOutput - estimatedOutput, 2.0)
            network.meanSquaredErrorList.append(meanSquaredError)

            epochs += 1

        }


        network.trainingError = error


        return network
    }



    private func teachNeuronOfLayer(numberOfInputNeurons: Int, line: Int, network: NeuralNet, netValue: Float, error: Float) -> [Neuron] {

        var listOfNeurons: [Neuron] = []
        var inputWeightsInOld: ValueArray<Float> = ValueArray<Float>()
        var inputWeightsInNew: [Float] = []

        for var j in 0..<numberOfInputNeurons {
            inputWeightsInOld = network.inputLayer.listOfNeurons[j].weightsComingIn
            var oldWeight = inputWeightsInOld[0]

            inputWeightsInNew.append(try! updateWeight(trainingType: network.trainingType, oldWeight: oldWeight, network: network, error: error, trainSample: network.trainingSet[line, j], netValue: netValue))

            var newNeuron = Neuron()
            newNeuron.weightsComingIn = ValueArray(inputWeightsInNew)

            listOfNeurons.append(newNeuron)
            inputWeightsInNew = []
        }

        return listOfNeurons
    }


    private func updateWeight(trainingType: TrainingType, oldWeight: Float, network: NeuralNet, error: Float, trainSample: Float, netValue: Float) throws -> Float {

        switch trainingType {
        case .PERCEPTRON:
            return oldWeight + network.learningRate * error * trainSample
        case .ADALINE:
            return oldWeight + network.learningRate * error * trainSample * (try! derivativeFunc(fncType: network.activationFuncType, value: netValue))
        default:
            throw MachineLearningError.invalidInput
        }

    }



    /**
     The activationFunc method returns the appropriate output based on the function that is specified.

     - parameter fncType: ActivationFunctionType enum case
     - parameter value: A Float

     - returns: A Float
     */
    public func activationFunc(fncType: ActivationFunctionType, value: Float) throws -> Float {

        switch fncType {
        case .STEP:
            return fncStep(val: value)
        case .LINEAR:
            return fncLinear(val: value)
        case .SIGLOG:
            return fncSigLog(val: value)
        case .HYPERTAN:
            return fncHyperTan(val: value)
        default:
            throw MachineLearningError.invalidInput
        }
    }

    /**
     The derivativeFunc method returns the appropriate output based on the derivative of a function that is specified.

     - parameter fncType: ActivationFunctionType enum case
     - parameter value: A Float

     - returns: A Float
     */
    public func derivativeFunc(fncType: ActivationFunctionType, value: Float) throws -> Float {

        switch fncType {
        case .LINEAR:
            return derivativeOfLinear(val: value)
        case .SIGLOG:
            return derivativeOfSigLog(val: value)
        case .HYPERTAN:
            return derivativeOfHyperTan(val: value)
        default:
            throw MachineLearningError.invalidInput
        }
    }


    private func fncStep(val: Float) -> Float {
        return val >= 0 ? 1.0 : 0.0
    }

    private func fncLinear(val: Float) -> Float {
        return val
    }

    private func fncSigLog(val: Float) -> Float {
        return 1.0 / (1.0 + exp(-val))
    }

    private func fncHyperTan(val: Float) -> Float {
        return tanh(val)
    }

    private func derivativeOfLinear(val: Float) -> Float {
        return 1.0
    }

    private func derivativeOfSigLog(val: Float) -> Float {
        return val * (1.0 - val)
    }

    private func derivativeOfHyperTan(val: Float) -> Float {
        return (1.0 / powf(cosh(val), 2.0))
    }


    private func printMultiLayerNetworkResult(trainedNetwork: NeuralNet) {

        var rows = trainedNetwork.trainingSet.rows
        var columns = trainedNetwork.trainingSet.columns

        var weightsComingIn: ValueArray<Float>! = ValueArray<Float>()


        for var i in 0..<rows {

            var netValue: Float = 0

            for var j in 0..<columns {
                weightsComingIn = trainedNetwork.inputLayer.listOfNeurons[j].weightsComingIn
                var inputWeight = weightsComingIn[0]
                netValue += inputWeight * trainedNetwork.trainingSet[i, j]

                print("\(trainedNetwork.trainingSet[i, j])")
            }

            print("\n")
            var estimatedOutput = try! activationFunc(fncType: trainedNetwork.activationFuncType, value: netValue)

            var colsOutput: Int = trainedNetwork.targetOutputMatrix.columns

            var realOutput: Float = 0.0

            for var k in 0..<colsOutput {
                realOutput += trainedNetwork.targetOutputMatrix[i, k]
            }


            print(" NET OUTPUT: \(estimatedOutput)")
            print(" REAL OUTPUT: \(realOutput)")

            var error: Float = estimatedOutput - realOutput
            print(" ERROR: \(error)")

            print("------------------------------------")
        }

    }

    private func printSingleLayerNetworkResult(trainedNetwork: NeuralNet) {

        var rows = trainedNetwork.trainingSet.rows
        var columns = trainedNetwork.trainingSet.columns

        var weightsComingIn: ValueArray<Float>! = ValueArray<Float>()


        for var i in 0..<rows {

            var netValue: Float = 0

            for var j in 0..<columns {
                weightsComingIn = trainedNetwork.inputLayer.listOfNeurons[j].weightsComingIn
                var inputWeight = weightsComingIn[0]
                netValue += inputWeight * trainedNetwork.trainingSet[i, j]

                print("\(trainedNetwork.trainingSet[i, j])")
            }

            print("\n")
            var estimatedOutput = try! activationFunc(fncType: trainedNetwork.activationFuncType, value: netValue)


            print("NET OUTPUT: \(estimatedOutput) \t")

            print("REAL OUTPUT: \(trainedNetwork.targetOutputSet[i]) \t")

            var error = estimatedOutput - trainedNetwork.targetOutputSet[i]

            print("ERROR: \(error) \t")


            print("------------------------------------")
        }

    }



    /**
     The printTrainedNetwork method prints the results of a trained Neural Network object.

     - parameter trainedNetwork: A trained Neural Network Object.
     - parameter singleLayer: Boolean to indicate whether or not your Neural Network has multiple layers.

     */
    public func printTrainedNetwork(trainedNetwork: NeuralNet, singleLayer: Bool) {

        if singleLayer {
            printSingleLayerNetworkResult(trainedNetwork: trainedNetwork)
        } else {
            printMultiLayerNetworkResult(trainedNetwork: trainedNetwork)
        }

    }

}
/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import { Contract, ContractFactory, Signer } from "ethers";
import { Provider } from "ethers/providers";
import { UnsignedTransaction } from "ethers/utils/transaction";

import { ComptrollerErrorReporter } from "./ComptrollerErrorReporter";

export class ComptrollerErrorReporterFactory extends ContractFactory {
  constructor(signer?: Signer) {
    super(_abi, _bytecode, signer);
  }

  deploy(): Promise<ComptrollerErrorReporter> {
    return super.deploy() as Promise<ComptrollerErrorReporter>;
  }
  getDeployTransaction(): UnsignedTransaction {
    return super.getDeployTransaction();
  }
  attach(address: string): ComptrollerErrorReporter {
    return super.attach(address) as ComptrollerErrorReporter;
  }
  connect(signer: Signer): ComptrollerErrorReporterFactory {
    return super.connect(signer) as ComptrollerErrorReporterFactory;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ComptrollerErrorReporter {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as ComptrollerErrorReporter;
  }
}

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "error",
        type: "uint256"
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "info",
        type: "uint256"
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "detail",
        type: "uint256"
      }
    ],
    name: "Failure",
    type: "event"
  }
];

const _bytecode =
  "0x6080604052348015600f57600080fd5b50603e80601d6000396000f3fe6080604052600080fdfea265627a7a7231582023f70230de5475494f9610f297eb7d9b1ea008178d4b13c0c3d2a9d563cfe84e64736f6c63430005100032";

/* Generated by ts-generator ver. 0.0.8 */
/* tslint:disable */

import { Contract, ContractTransaction, EventFilter, Signer } from "ethers";
import { Listener, Provider } from "ethers/providers";
import { Arrayish, BigNumber, BigNumberish, Interface } from "ethers/utils";
import {
  TransactionOverrides,
  TypedEventDescription,
  TypedFunctionDescription
} from ".";

interface CDelegatorInterfaceInterface extends Interface {
  functions: {
    _setImplementation: TypedFunctionDescription<{
      encode([implementation_, allowResign, becomeImplementationData]: [
        string,
        boolean,
        Arrayish
      ]): string;
    }>;

    implementation: TypedFunctionDescription<{ encode([]: []): string }>;
  };

  events: {
    NewImplementation: TypedEventDescription<{
      encodeTopics([oldImplementation, newImplementation]: [
        null,
        null
      ]): string[];
    }>;
  };
}

export class CDelegatorInterface extends Contract {
  connect(signerOrProvider: Signer | Provider | string): CDelegatorInterface;
  attach(addressOrName: string): CDelegatorInterface;
  deployed(): Promise<CDelegatorInterface>;

  on(event: EventFilter | string, listener: Listener): CDelegatorInterface;
  once(event: EventFilter | string, listener: Listener): CDelegatorInterface;
  addListener(
    eventName: EventFilter | string,
    listener: Listener
  ): CDelegatorInterface;
  removeAllListeners(eventName: EventFilter | string): CDelegatorInterface;
  removeListener(eventName: any, listener: Listener): CDelegatorInterface;

  interface: CDelegatorInterfaceInterface;

  functions: {
    _setImplementation(
      implementation_: string,
      allowResign: boolean,
      becomeImplementationData: Arrayish,
      overrides?: TransactionOverrides
    ): Promise<ContractTransaction>;

    implementation(): Promise<string>;
  };

  _setImplementation(
    implementation_: string,
    allowResign: boolean,
    becomeImplementationData: Arrayish,
    overrides?: TransactionOverrides
  ): Promise<ContractTransaction>;

  implementation(): Promise<string>;

  filters: {
    NewImplementation(
      oldImplementation: null,
      newImplementation: null
    ): EventFilter;
  };

  estimate: {
    _setImplementation(
      implementation_: string,
      allowResign: boolean,
      becomeImplementationData: Arrayish
    ): Promise<BigNumber>;

    implementation(): Promise<BigNumber>;
  };
}
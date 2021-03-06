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

interface TokenErrorReporterInterface extends Interface {
  functions: {};

  events: {
    Failure: TypedEventDescription<{
      encodeTopics([error, info, detail]: [null, null, null]): string[];
    }>;
  };
}

export class TokenErrorReporter extends Contract {
  connect(signerOrProvider: Signer | Provider | string): TokenErrorReporter;
  attach(addressOrName: string): TokenErrorReporter;
  deployed(): Promise<TokenErrorReporter>;

  on(event: EventFilter | string, listener: Listener): TokenErrorReporter;
  once(event: EventFilter | string, listener: Listener): TokenErrorReporter;
  addListener(
    eventName: EventFilter | string,
    listener: Listener
  ): TokenErrorReporter;
  removeAllListeners(eventName: EventFilter | string): TokenErrorReporter;
  removeListener(eventName: any, listener: Listener): TokenErrorReporter;

  interface: TokenErrorReporterInterface;

  functions: {};

  filters: {
    Failure(error: null, info: null, detail: null): EventFilter;
  };

  estimate: {};
}

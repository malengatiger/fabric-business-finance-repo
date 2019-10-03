import { Network, Contract, Gateway, GatewayOptions, FileSystemWallet } from 'fabric-network';
import { Channel, Peer, ChannelPeer } from 'fabric-client';
import { CloudantService } from './cloudant-service';
import { Constants } from '../models/constants';
const z = '\n\n';
/*

*/
export class ConnectToChaincode {

  public static async getContract(userName: string, wallet: FileSystemWallet): Promise<Contract> {
    const start1 = new Date().getTime();

    const profile = await CloudantService.getConnectionProfile();
    const gateway: Gateway = new Gateway();
    const options: GatewayOptions = {
      wallet: wallet,
      identity: userName,
      discovery: {
        enabled: true,
        asLocalhost: false
      }
    };
    const start2 = new Date().getTime();
    const elapsed1 = (start2 - start1) / 1000
    await gateway.connect(profile, options);
    const start3 = new Date().getTime();
    try {
      const network: Network = await gateway.getNetwork(Constants.DEFAULT_CHANNEL);
      const contract: Contract = network.getContract(Constants.DEFAULT_CHAINCODE);
      const start4 = new Date().getTime();
      const elapsed4 = (start4 - start3) / 1000
      console.log(`⌛️ ⌛️ ⌛️ --> Contract object instantiation took 💦 ${elapsed4} seconds `)

      return contract;
    } catch (e) {
      console.error(`${z} Failed to obtain Contract object : ${e}`);
      throw e;
    }

  }
}
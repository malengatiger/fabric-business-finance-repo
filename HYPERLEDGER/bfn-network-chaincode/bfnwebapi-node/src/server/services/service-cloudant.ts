import { Application } from "express-serve-static-core";

const IBMCloudEnv = require('ibm-cloud-env');
const CloudantSDK = require('@cloudant/cloudant');

const cloudantURL = "https://2f9950cd-d6e8-4398-8f10-546090298325-bluemix:056a61bdb6c9c2e014def6d4cf11fc24f66f7e512db1f2f0c2d667070cfc58f4@2f9950cd-d6e8-4398-8f10-546090298325-bluemix.cloudantnosqldb.appdomain.cloud";

module.exports = function(app: Application, serviceManager: { set: (arg0: string, arg1: any) => void; }){
	// const cloudant = new CloudantSDK(IBMCloudEnv.getString('cloudant_url'));
	const cloudant = new CloudantSDK(cloudantURL);
	serviceManager.set('cloudant', cloudant);
};

export default class OldCloudantService {

}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const tslib_1 = require("tslib");
const constants_1 = require("../models/constants");
const formData = require('form-data');
const axios = require('axios');
class AxiosComms {
    static execute(url, data) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const start = new Date().getTime();
            const mresponse = yield axios({
                method: 'post',
                url: url,
                data: data
            }).catch((error) => {
                if (error.response) {
                    // The request was made and the server responded with a status code
                    // that falls out of the range of 2xx
                    console.log(error.response.data);
                }
                else if (error.request) {
                    // The request was made but no response was received
                    // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
                    // http.ClientRequest in node.js
                    console.log(error.request);
                }
                else {
                    // Something happened in setting up the request that triggered an Error
                    console.log('Something happened in setting up the request that triggered an Error: ', error.message);
                }
                console.log(error);
                throw new Error(error.response.data);
            });
            const end = new Date().getTime();
            const elapsedSeconds = (end - start) / 1000;
            console.log(`## Axios comms status: ${mresponse.status} after: ${url} * elapsed: ${elapsedSeconds} seconds`);
            return mresponse;
        });
    }
    static get(url) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const start = new Date().getTime();
            const mresponse = yield axios({
                method: 'get',
                url: url
            }).catch((error) => {
                if (error.response) {
                    // The request was made and the server responded with a status code
                    // that falls out of the range of 2xx
                    console.log(error.response.data);
                }
                else if (error.request) {
                    // The request was made but no response was received
                    // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
                    // http.ClientRequest in node.js
                    console.log(error.request);
                }
                else {
                    // Something happened in setting up the request that triggered an Error
                    console.log('Something happened in setting up the request that triggered an Error: ', error.message);
                }
                console.log(error);
                throw new Error(error.response.data);
            });
            const end = new Date().getTime();
            const elapsedSeconds = (end - start) / 1000;
            console.log(`## Axios comms status: ${mresponse.status} after: ${url} * elapsed: ${elapsedSeconds} seconds`);
            return mresponse;
        });
    }
    static executeTransaction(functionName, jsonString, chaincode, channel, userName) {
        return tslib_1.__awaiter(this, void 0, void 0, function* () {
            const start = new Date().getTime();
            const url = constants_1.Constants.DEBUG_BFN_URL + "sendTransaction";
            const bodyFormData = new formData();
            if (!chaincode) {
                bodyFormData.append('chaincode', constants_1.Constants.DEFAULT_CHAINCODE);
            }
            else {
                bodyFormData.append('chaincode', chaincode);
            }
            if (!channel) {
                bodyFormData.append('channel', constants_1.Constants.DEFAULT_CHANNEL);
            }
            else {
                bodyFormData.append('channel', channel);
            }
            if (!userName) {
                bodyFormData.append('userName', constants_1.Constants.DEFAULT_USERNAME);
            }
            else {
                bodyFormData.append('userName', userName);
            }
            bodyFormData.append('function', functionName);
            bodyFormData.append('jsonString', jsonString);
            const mresponse = yield axios({
                method: 'post',
                url: url,
                data: bodyFormData
            }).catch((error) => {
                if (error.response) {
                    // The request was made and the server responded with a status code
                    // that falls out of the range of 2xx
                    console.log(error.response.data);
                }
                else if (error.request) {
                    // The request was made but no response was received
                    // `error.request` is an instance of XMLHttpRequest in the browser and an instance of
                    // http.ClientRequest in node.js
                    console.log(error.request);
                }
                else {
                    // Something happened in setting up the request that triggered an Error
                    console.log('Something happened in setting up the request that triggered an Error: ', error.message);
                }
                console.log(error);
                throw new Error(error.response.data);
            });
            const end = new Date().getTime();
            const elapsedSeconds = (end - start) / 1000;
            console.log(`## Axios comms status: ${mresponse.status} after: ${url} * elapsed: ${elapsedSeconds} seconds`);
            return mresponse;
        });
    }
}
exports.AxiosComms = AxiosComms;
//# sourceMappingURL=axios-comms.js.map
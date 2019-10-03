// import lodash from "lodash";
import { WalletCache } from "../models/wallet-cache";
const Cloudant = require("@cloudant/cloudant");
require("dotenv").load();
const account: string = process.env.CLOUDANT_USERNAME || "";
const key: string = process.env.CLOUDANT_API_KEY || "";
const password: string = process.env.CLOUDANT_API_PASSWORD || "";
const cloudantUrl: string = process.env.CLOUDANT_URL || "";
const DATABASE: string = "bfnwallets";
let db: any;
const zz = "\n";
/*

*/

export class CloudantService {
  private static cloudant: any;

  constructor() { }

  // NEEDS _admin permission
  public static async createDatabase(dbName: string): Promise<{} | null> {

    return new Promise<{} | null>((resolve, reject) => {
      this.cloudant.db.create(dbName, (err: Error, body: any, header: any) => {
        if (err) {
          console.error(err);
          reject(null);
          return;
        }
        console.log("Create Database");
        console.log(body);
        resolve(body);
      });
    });
  }
  // NEEDS _admin permission
  public static async dropDatabase(dbName: string): Promise<{} | null> {
    return new Promise<{} | null>((resolve, reject) => {
      this.cloudant.db.destroy(dbName, (err: Error, body: any, header: any) => {
        if (err) {
          console.error(err);
          reject(null);
          return;
        }
        console.log("Destroy Database");
        console.log(body);
        resolve(body);
      });
    });
  }
  private static use(): any {
    //console.log(`\n\n😡  😡 😡  😡  --->  account: ${account} apiKey: ${key} pswd: ${password} 😡  😡 😡  😡`)
    try {
      if (!this.cloudant) {
        //this.cloudant = Cloudant({ account, key, password });
        console.log(`😡 😡 😡 😡   **** using url to connect to cloudant:  💦 💦 ${cloudantUrl} ......`)
        this.cloudant = Cloudant({ url: cloudantUrl });
        console.log(`cloudant accessed OK 💦 💦 ${this.cloudant}`)

      }
      db = this.cloudant.db.use(DATABASE);
    } catch (e) {
      console.error(`${zz}👿 👿 👿 👿 cloudant fucked: ${e}${zz}`);
    }
    return db;
  }
  public static async getDatabaseCreds() {
    try {
      const db = this.use();
      if (!db) {
        console.error(`👿 👿 👿 👿 cloudant db not. good. bad. terrible. `);
      } else {
        console.log(`${zz}💕 💕  - db seems OK 💕 💕 ${db} ${zz}`);
      }
    } catch (e) {
      console.error(`${zz}👿 👿 👿 👿 db failed: 👿 👿 👿 👿\n ${e} ${zz}`);
    }
    return {
      apiKey: key,
      account: account,
      password: password
    };
  }
  public static async getConnectionProfile(): Promise<any> {
    db = this.use();
    console.log(`😡 😡 😡 😡  ----   getting ConnectionProfile ... from cloudant: 💦 ${db} ---- 😡 😡 😡 😡`);
    return new Promise<any>((resolve, reject) => {
      db.get("connectionProfile", (err: Error, data: any, headers: any) => {
        if (err) {
          console.error(`\n\n👿 👿 👿 connectionProfile error: ${err}`);
          reject(null);
          return;
        } else {
          console.log(`❤️  ❤️  ❤️ - we seem to be kool here: ${data}`)
          console.log(data);
          console.log('🔵 🔵 🔵 🔵 🔵 🔵 🔵 🔵 ')
          console.log(data.certificateAuthorities)
        }

        const mData = data;
        resolve(mData);
      });
    });
  }
  public static async getConfig(): Promise<any> {
    db = this.use();
    console.log(`${zz}😡 😡  ----   getConfig ...${zz}`);
    return new Promise<any>((resolve, reject) => {
      const db = this.use();
      db.get("config", (err: Error, data: any, headers: any) => {
        if (err) {
          console.error(err);
          reject(null);
          return;
        }
        console.log(
          `${zz}💙  💚  data returned for config call:${zz} ${JSON.stringify(
            data
          )} ${zz}`
        );
        const mData = data.json;
        resolve(mData);
      });
    });
  }
  public static async insertWalletCache<T>(
    walletCache: WalletCache
  ): Promise<any> {
    // console.log(`\n🙄 🙄 🙄 getting existing wallet, if any`);
    db = this.use();
    try {
      const cache: any = await this.getWalletCache(walletCache._id);
      if (cache.data !== null) {
        // console.log(
        //   `${zz}💕 💕   returned cache ${cache.data._id} rev: ${cache.data._rev} will do delete now`
        // );
        await this.deleteWalletCache(cache.data._id, cache.data._rev);
      }
      // console.log(
      //   `${zz}🔵 🔵 🔵 🔵   we do not have a cache! -- INSERT it NOW`
      // );
      try {
        db.insert({
          _id: walletCache._id,
          data: walletCache.toJson()
        });
        console.log(
          `${zz}💙  💚  💛 💙  💚  💛  -- wallet written to cloudant ....${zz}`
        );
      } catch (e) {
        console.error(
          `${zz}\n😡 😡 😡 😡 😡 😡  ---- @@@@@@@@@@ error here, unable to insert: ${zz}${e}`
        );
      }
    } catch (e) {
      console.log(
        `${zz}\n 😡 😡 😡 😡 😡 😡  .....  Fell down here .....${zz}`
      );
      console.error(e);
      throw e;
    }
  }

  public static async getWalletCache(_id: string): Promise<any> {
    let cache: WalletCache;
    db = this.use();
    // console.log(`${zz}😡 😡  ----   getWalletCache ...${zz}`);
    return new Promise<any>((resolve, reject) => {
      db.get(_id, (err: Error, data: any, headers: any) => {
        if (err) {
          console.error(err);
          resolve({
            data: null
          });
          return;
        }

        // console.log(
        //   `${zz}💙  💚  💛 💙  💚  💛  data returned for get call:${zz} ${JSON.stringify(
        //     data
        //   )} ${zz}`
        // );
        const mData = data.data;
        cache = new WalletCache();
        cache.fromJson(mData);
        resolve({
          cache: cache,
          data: data
        });
      });
    });
  }

  public static async deleteWalletCache(
    _id: string,
    _rev: string
  ): Promise<{} | null> {
    return new Promise<{} | null>((resolve, reject) => {
      const db = this.use();
      db.destroy(_id, _rev, (err: Error, body: any, header: any) => {
        if (err) {
          console.error(err);
          reject(() => {
            const msg = `Database delete failed - ${err}`;
            console.log(msg);
            throw new Error(msg);
          });
          return;
        }
        console.log(`Document deleted`);
        console.log(`body returned: ${body}`);
        resolve(body);
      });
    });
  }

  public static async searchDocument<T>(
    designName: string,
    indexName: string,
    searchText: string
  ): Promise<T | null> {
    return new Promise<T | null>((resolve, reject) => {
      const db = this.use();
      db.search(
        designName,
        indexName,
        { q: searchText },
        (err: Error, result: any, header: any) => {
          if (err) {
            console.error(err);
            reject(null);
            return;
          }
          console.log("Search Document");
          console.log(result);
          resolve(result);
        }
      );
    });
  }
}

export interface DocumentBase {
  _id?: string;
  _rev?: string;
}

export interface SearchResult<T> {
  total_rows: number;
  bookmark: string;
  rows: SearchResultRow<T>[];
}

interface SearchResultRow<T> {
  id: string;
  order: number[];
  fields: T;
}

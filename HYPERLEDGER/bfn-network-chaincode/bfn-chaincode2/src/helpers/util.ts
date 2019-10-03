
export class Util {
    // generic helper method
    public static getList(result) {
        const mList = [];
        result.response.results.forEach((buffer) => {
            const json = buffer.resultBytes.toString('utf8');
            const index = json.indexOf('{');
            const raw = JSON.parse(json.substring(index));
            mList.push(raw);
        });
        return {
            list: mList,
            message: `💚  💚 SmartContract evaluated OK: ${new Date().toISOString()}  items: ${mList.length} 💚  💚`,
            statusCode: 200,
        };
    }
    public static getObject(result) {
        let obj;
        result.response.results.forEach((buffer) => {
            const json = buffer.resultBytes.toString('utf8');
            const index = json.indexOf('{');
            obj = JSON.parse(json.substring(index));
        });
        return obj;
    }

    public static sendError(msg: string) {
        console.error(`👿 👿 👿 🙄 ${msg}  🙄 👿 👿 👿 `);
        const ret = `👿 👿 👿  ${msg}   👿 👿 👿`;
        return {
            message: ret,
            statusCode: 400,
        };
    }
    public static sendResult(obj: any) {
        return {
            message: `💚  💚  💚  SmartContract executed OK: 😎 ${new Date().toISOString()}  ❤️ ❤️ ❤️`,
            result: obj,
            statusCode: 200,
        };
    }
}

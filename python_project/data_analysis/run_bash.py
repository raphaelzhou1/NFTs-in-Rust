import asyncio
import json
from aiohttp import ClientSession

async def run_command(session: ClientSession):

    cw20 = "sei1xmsxzq9up5y2gj6e3fxmuqu4hvr2v0yu7qt34qn6amqpcxmejeuqlumuvk"
    address = "sei0"
    command = f"/Users/tianyu/go/bin/seid q wasm contract-state smart {cw20} '{{ \"all_accounts\": {{ \"start_after\": \"{address}\", \"limit\": 10000 }} }}' --output json  --chain-id atlantic-2 --node=https://rpc.atlantic-2.seinetwork.io"
    print(command)

    while True:
        proc = await asyncio.create_subprocess_exec(*command, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)

        stdout, stderr = await proc.communicate()

        if proc.returncode != 0:
            print(f"An error occurred: {stderr.decode().strip()}")
            break

        json_output = json.loads(stdout.decode().strip())
        print(json_output)

        await asyncio.sleep(2)  # sleeps for 2 seconds before running the command again

async def main():
    async with ClientSession() as session:
        await run_command(session)

if __name__ == "__main__":
    asyncio.run(main())  # Simplified running of async main function in Python 3.10

import { IncomingMessage, createServer } from 'http';
import { getRandomPort } from 'get-port-please';

export const mockTokenRegistry = (handler: (req?: IncomingMessage) => { body?: unknown; code?: number } = () => ({})) =>
  // eslint-disable-next-line func-call-spacing
  new Promise<{ closeMock: () => Promise<void>; serverUrl: string }>(async (resolve, reject) => {
    try {
      const port = await getRandomPort();
      const server = createServer(async (req, res) => {
        const { body, code } = handler(req);

        res.setHeader('Content-Type', 'application/json');

        if (body) {
          res.statusCode = code || 200;

          return res.end(JSON.stringify(body));
        }

        const buffers: Buffer[] = [];
        for await (const chunk of req) buffers.push(chunk);
        const data = Buffer.concat(buffers).toString();
        const subjects: unknown[] = [];

        for (const subject of JSON.parse(data).subjects) {
          const mockResult = {
            description: { value: 'This is my first NFT of the macaron cake' },
            name: { value: 'macaron cake token' },
            subject: subject as string
          };

          if (mockResult) subjects.push(mockResult);
        }

        return res.end(JSON.stringify({ subjects }));
      });

      let resolver: () => void = jest.fn();
      let rejecter: (reason: unknown) => void = jest.fn();

      // eslint-disable-next-line @typescript-eslint/no-shadow
      const closePromise = new Promise<void>((resolve, reject) => {
        resolver = resolve;
        rejecter = reject;
      });

      server.on('error', rejecter);
      server.listen(port, 'localhost', () =>
        resolve({
          closeMock: () => {
            server.close((error) => (error ? rejecter(error) : resolver()));
            return closePromise;
          },
          serverUrl: `http://localhost:${port}`
        })
      );
    } catch (error) {
      reject(error);
    }
  });

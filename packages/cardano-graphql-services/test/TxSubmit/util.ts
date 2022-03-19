import waitOn from 'wait-on';

export const serverReady = (apiUrlBase: string): Promise<void> =>
  waitOn({ resources: [`${apiUrlBase}`], validateStatus: (status: number) => status === 404 });

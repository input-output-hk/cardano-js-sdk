import { ThrowReporter } from 'io-ts/lib/ThrowReporter'
import { EmptyArray } from './errors'

export function validateCodec<Codec extends {decode: Function}> (codec: Codec, data: any[] | any) {
  if (Array.isArray(data)) {
    if (!data.length) {
      throw new EmptyArray()
    }

    data.forEach(dataEntry => {
      throwIfDecodeFails(codec, dataEntry)
    })
  } else {
    throwIfDecodeFails(codec, data)
  }
}

function throwIfDecodeFails<Codec extends {decode: Function}> (codec: Codec, data: any) {
  const decodingResult = codec.decode(data)
  ThrowReporter.report(decodingResult)
}

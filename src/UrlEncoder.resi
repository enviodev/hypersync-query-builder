let serializeQuery: QueryStructure.query => string
let deserializeQuery: string => option<QueryStructure.query>
let encodeQueryToUrl: QueryStructure.query => string
let decodeQueryFromUrl: string => option<QueryStructure.query>
let getQueryFromUrl: unit => option<QueryStructure.query>
let updateUrlWithQuery: QueryStructure.query => unit 
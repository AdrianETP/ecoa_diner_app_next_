module.exports = {
    productionBrowserSourceMaps: true,
    compress: true,
    poweredByHeader: false,
    headers: async () => [
        {
            source: '/(.*).js.br',
            headers: [
                {
                    key: 'Content-Encoding',
                    value: 'br',
                },
            ],
        },
    ],
};

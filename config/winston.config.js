const { createLogger, format, transports } = require('winston');
const { combine, timestamp, json, printf, splat } = format;
const logger = createLogger({
    format: combine(
        timestamp({
            format: 'YYYY-MM-DD HH:mm:ss'
        }),
        json(),
    ),
    defaultMeta: { service: 'metadata-api' },
    transports: [
        new transports.File({
            filename: 'logs/error.log',
            level: 'error',
            json: true,
            maxsize: 5242880, // 5MB
           }),
        new transports.File({
            filename: 'logs/combined.log',
            json: true,
            maxsize: 5242880,
        })
    ],
    exitOnError: false,
});

if (process.env.NODE_ENV !== 'production') {
    
    // meta param is ensured by splat()
    const myFormat =   printf(info => {
    
        delete info.message.addresses
       
        return `${info.timestamp} [${info.level}] : ${JSON.stringify(info.message)}`;
    })
        
        // printf(({ timestamp, level, message, meta }) => {
        // return `${timestamp};${level};${message};${meta};${meta? JSON.stringify(meta) : ''}`;
    // });
    
    logger.add(new transports.Console({
        // format: format.simple(),
        format:combine(
            timestamp(),
            // splat(),
            myFormat),
        colorize: true,
    }));
}

module.exports.logger = logger;

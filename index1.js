console.log('Loading function1');

var AWS = require('aws-sdk');
var dynamo = new AWS.DynamoDB.DocumentClient();
var tableName = "dyndb-table1";

/**
 * Provide an event that contains the following keys:
 *
 *   - operation: one of the operations in the switch statement below, or 'echo'
 *   - payload: a parameter to pass to the operation being performed
 */
exports.handler = function(event, context, callback) {
    
    var operation = event.operation;

    if (operation == 'echo'){
        callback(null, event.payload);
    }
        
    else{
        event.payload.TableName = tableName;

    switch (operation) {
        case 'create':
            dynamo.put(event.payload, callback);
            break;
        case 'read':
            dynamo.get(event.payload, callback);
            break;
        case 'update':
            dynamo.update(event.payload, callback);
            break;
        case 'delete':
            dynamo.delete(event.payload, callback);
            break;
        case 'list':
            dynamo.scan(event.payload, callback);
            break;
        default:
            callback(`Unknown operation: ${operation}`);
    }
}
};

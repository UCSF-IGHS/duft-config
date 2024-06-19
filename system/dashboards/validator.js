const schema = {
    name: 'string',
    title: 'string',
    version: 'number',
    releaseDate: 'string',
    slicers: [
      {
        name: 'string',
        type: 'string',
        options: 'string'
      }
    ],
    tabs: [
      {
        id: 'number',
        title: 'string',
        badge: {
          query: 'string',
          color: {
            high: {
              upperThreshold: 'number',
              lowerThreshold: 'number',
              hex: 'string'
            },
            medium: {
              upperThreshold: 'number',
              lowerThreshold: 'number',
              hex: 'string'
            },
            low: {
              upperThreshold: 'number',
              lowerThreshold: 'number',
              hex: 'string'
            }
          }
        },
        tiles: [
          {
            id: 'number',
            label: 'string',
            format: 'string',
            query: 'string',
            totalCounter: 'string',
            icon: 'string'
          }
        ],
        visuals: [
          {
            id: 'number',
            groupBy: 'string',
            col: 'number',
            label: 'string',
            title: 'string',
            type: 'string',
            y: {
              label: 'string',
              column: 'string',
              format: 'string',
              action: 'string'
            },
            x: {
              label: 'string',
              column: 'string',
              format: 'string'
            },
            query: 'string'
          },
          {
            id:'number',
            label: 'string',
            title: 'string',
            type: 'table',
            groupBy: 'string',
            sortable: true,
            columns: {
              '*': {
                label: 'string',
                column: 'string',
                format: 'string',
                sort: 'number'
              }
            },
            query: 'string'
          }
        ]
      }
    ]
  };
  // Function to validate if an object matches the schema
const validateSchema = (obj, schema, path = '') => {
    const errors = [];
   // looping through each key in schema
    for (const key in schema) {
      const keyPath = path ? `${path}.${key}` : key; 
      const expectedType = schema[key];

      //are we handling an array?
      if (Array.isArray(expectedType)) {

        // not an array?
        if (!Array.isArray(obj[key])) {
          errors.push(`🫤 Expected an array at "${keyPath}", but got ➡ ${typeof obj[key]}.`);
        } else {
            //ok good, you are array, but lets check each of your items
          obj[key].forEach((item, index) => {
            //... we are using this to unpack items in the errors array, and we recusively validate the items
            errors.push(...validateSchema(item, expectedType[0], `${keyPath}[${index}]`));
          });
        }
      } 
      else if (typeof expectedType === 'object') {
            //obj[key] not object or is array, push error message
        if (typeof obj[key] !== 'object' || Array.isArray(obj[key])) {
          errors.push(`🫤 Expected an object at "${keyPath}", but got ${typeof obj[key]}.`);
        } else {
            // ok cool its an object, lets validate it
          errors.push(...validateSchema(obj[key], expectedType, keyPath));
        }
      }
      //does expected type match the type of obj[key]?
      else if (typeof obj[key] !== expectedType) {
        //if it doesn't match, push this error message
        errors.push(`🥲 Expected a ${expectedType} at "${keyPath}", but got ${typeof obj[key]}.`);
      }
    }
  
    return errors;
  };
  
  // Function to validate the entire JSON
  const validateJSON = (json) => {
    const errors = validateSchema(json, schema);
    if (errors.length) {
      console.log(`Invalid JSON:\n${errors.join('\n')}`);
      return false;
    }
    console.log('JSON is valid');
    return true;
  };
  // Example JSON input
const exampleJSON = {
  name: "dashboard-wakanda.json",
  title: "Sample Wakanda Dashboard",
  version: 3,
  visuals: [
    // Visuals data here
  ]
};
// Call validateJSON with exampleJSON
validateJSON(exampleJSON);
/*
   Licensed to the Apache Software Foundation (ASF) under one or more
   contributor license agreements.  See the NOTICE file distributed with
   this work for additional information regarding copyright ownership.
   The ASF licenses this file to You under the Apache License, Version 2.0
   (the "License"); you may not use this file except in compliance with
   the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
var showControllersOnly = false;
var seriesFilter = "";
var filtersOnlySampleSeries = true;

/*
 * Add header in statistics table to group metrics by category
 * format
 *
 */
function summaryTableHeader(header) {
    var newRow = header.insertRow(-1);
    newRow.className = "tablesorter-no-sort";
    var cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Requests";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 3;
    cell.innerHTML = "Executions";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 7;
    cell.innerHTML = "Response Times (ms)";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 1;
    cell.innerHTML = "Throughput";
    newRow.appendChild(cell);

    cell = document.createElement('th');
    cell.setAttribute("data-sorter", false);
    cell.colSpan = 2;
    cell.innerHTML = "Network (KB/sec)";
    newRow.appendChild(cell);
}

/*
 * Populates the table identified by id parameter with the specified data and
 * format
 *
 */
function createTable(table, info, formatter, defaultSorts, seriesIndex, headerCreator) {
    var tableRef = table[0];

    // Create header and populate it with data.titles array
    var header = tableRef.createTHead();

    // Call callback is available
    if(headerCreator) {
        headerCreator(header);
    }

    var newRow = header.insertRow(-1);
    for (var index = 0; index < info.titles.length; index++) {
        var cell = document.createElement('th');
        cell.innerHTML = info.titles[index];
        newRow.appendChild(cell);
    }

    var tBody;

    // Create overall body if defined
    if(info.overall){
        tBody = document.createElement('tbody');
        tBody.className = "tablesorter-no-sort";
        tableRef.appendChild(tBody);
        var newRow = tBody.insertRow(-1);
        var data = info.overall.data;
        for(var index=0;index < data.length; index++){
            var cell = newRow.insertCell(-1);
            cell.innerHTML = formatter ? formatter(index, data[index]): data[index];
        }
    }

    // Create regular body
    tBody = document.createElement('tbody');
    tableRef.appendChild(tBody);

    var regexp;
    if(seriesFilter) {
        regexp = new RegExp(seriesFilter, 'i');
    }
    // Populate body with data.items array
    for(var index=0; index < info.items.length; index++){
        var item = info.items[index];
        if((!regexp || filtersOnlySampleSeries && !info.supportsControllersDiscrimination || regexp.test(item.data[seriesIndex]))
                &&
                (!showControllersOnly || !info.supportsControllersDiscrimination || item.isController)){
            if(item.data.length > 0) {
                var newRow = tBody.insertRow(-1);
                for(var col=0; col < item.data.length; col++){
                    var cell = newRow.insertCell(-1);
                    cell.innerHTML = formatter ? formatter(col, item.data[col]) : item.data[col];
                }
            }
        }
    }

    // Add support of columns sort
    table.tablesorter({sortList : defaultSorts});
}

$(document).ready(function() {

    // Customize table sorter default options
    $.extend( $.tablesorter.defaults, {
        theme: 'blue',
        cssInfoBlock: "tablesorter-no-sort",
        widthFixed: true,
        widgets: ['zebra']
    });

    var data = {"OkPercent": 99.93018384919712, "KoPercent": 0.06981615080288574};
    var dataset = [
        {
            "label" : "FAIL",
            "data" : data.KoPercent,
            "color" : "#FF6347"
        },
        {
            "label" : "PASS",
            "data" : data.OkPercent,
            "color" : "#9ACD32"
        }];
    $.plot($("#flot-requests-summary"), dataset, {
        series : {
            pie : {
                show : true,
                radius : 1,
                label : {
                    show : true,
                    radius : 3 / 4,
                    formatter : function(label, series) {
                        return '<div style="font-size:8pt;text-align:center;padding:2px;color:white;">'
                            + label
                            + '<br/>'
                            + Math.round10(series.percent, -2)
                            + '%</div>';
                    },
                    background : {
                        opacity : 0.5,
                        color : '#000'
                    }
                }
            }
        },
        legend : {
            show : true
        }
    });

    // Creates APDEX table
    createTable($("#apdexTable"), {"supportsControllersDiscrimination": true, "overall": {"data": [0.9975135135135135, 500, 1500, "Total"], "isController": false}, "titles": ["Apdex", "T (Toleration threshold)", "F (Frustration threshold)", "Label"], "items": [{"data": [0.9984894259818731, 500, 1500, "POST Create Acte"], "isController": false}, {"data": [0.9817073170731707, 500, 1500, "SCENARIO: Patient Lifecycle"], "isController": true}, {"data": [0.996969696969697, 500, 1500, "GET Sejour"], "isController": false}, {"data": [1.0, 500, 1500, "GET Patient"], "isController": false}, {"data": [1.0, 500, 1500, "POST Create Sejour"], "isController": false}, {"data": [1.0, 500, 1500, "DELETE Patient"], "isController": false}, {"data": [0.9969604863221885, 500, 1500, "DELETE Medecin"], "isController": false}, {"data": [1.0, 500, 1500, "PUT Update Acte"], "isController": false}, {"data": [0.9984802431610942, 500, 1500, "DELETE Acte"], "isController": false}, {"data": [0.9954819277108434, 500, 1500, "POST Create Medecin"], "isController": false}, {"data": [0.996969696969697, 500, 1500, "GET Medecin"], "isController": false}, {"data": [1.0, 500, 1500, "DELETE Sejour"], "isController": false}, {"data": [1.0, 500, 1500, "POST Create Service"], "isController": false}, {"data": [1.0, 500, 1500, "POST Create Patient"], "isController": false}]}, function(index, item){
        switch(index){
            case 0:
                item = item.toFixed(3);
                break;
            case 1:
            case 2:
                item = formatDuration(item);
                break;
        }
        return item;
    }, [[0, 0]], 3);

    // Create statistics table
    createTable($("#statisticsTable"), {"supportsControllersDiscrimination": true, "overall": {"data": ["Total", 4297, 3, 0.06981615080288574, 9.772399348382596, 3, 1449, 8.0, 11.0, 12.0, 20.0, 71.85258264635554, 39.37797265082855, 36.6487806840794], "isController": false}, "titles": ["Label", "#Samples", "FAIL", "Error %", "Average", "Min", "Max", "Median", "90th pct", "95th pct", "99th pct", "Transactions/s", "Received", "Sent"], "items": [{"data": ["POST Create Acte", 331, 0, 0.0, 13.1570996978852, 6, 1449, 8.0, 12.0, 14.0, 17.680000000000007, 5.5915940266234205, 3.1507321810172986, 3.4401408562233935], "isController": false}, {"data": ["SCENARIO: Patient Lifecycle", 328, 1, 0.3048780487804878, 127.05182926829264, 84, 1536, 95.0, 140.10000000000002, 148.55, 1530.1299999999999, 5.5512304099109775, 39.52175840617913, 36.7768022987679], "isController": true}, {"data": ["GET Sejour", 330, 0, 0.0, 14.624242424242453, 4, 1447, 5.0, 7.0, 9.0, 37.93999999999994, 5.5911355087933305, 3.8275253824844975, 2.145816655230253], "isController": false}, {"data": ["GET Patient", 331, 0, 0.0, 5.622356495468279, 4, 51, 5.0, 7.0, 8.0, 11.680000000000007, 5.593294805502045, 3.5832044847747477, 2.152107571648248], "isController": false}, {"data": ["POST Create Sejour", 332, 0, 0.0, 9.16867469879518, 7, 55, 8.0, 12.0, 14.0, 29.720000000000255, 5.590354953862733, 3.8269910377517347, 3.444837867077524], "isController": false}, {"data": ["DELETE Patient", 328, 0, 0.0, 8.33841463414634, 6, 55, 8.0, 11.0, 11.550000000000011, 17.0, 5.602815072939086, 1.8165376994294693, 2.276143623381504], "isController": false}, {"data": ["DELETE Medecin", 329, 1, 0.303951367781155, 8.659574468085102, 6, 23, 8.0, 11.0, 12.0, 17.399999999999977, 5.595333253966904, 2.0998609935968298, 2.273054308959336], "isController": false}, {"data": ["PUT Update Acte", 330, 0, 0.0, 9.648484848484845, 6, 79, 8.0, 13.0, 15.0, 52.139999999999986, 5.590472479628657, 3.182856890257331, 3.5868558780429955], "isController": false}, {"data": ["DELETE Acte", 329, 0, 0.0, 13.003039513677816, 6, 1436, 8.0, 12.0, 14.0, 23.0, 5.595523581135092, 1.8141736610711432, 2.2567883193445244], "isController": false}, {"data": ["POST Create Medecin", 332, 1, 0.30120481927710846, 13.397590361445788, 6, 1449, 8.0, 11.0, 12.349999999999966, 36.670000000000016, 5.587814524951612, 4.069988376251788, 3.770683434317933], "isController": false}, {"data": ["GET Medecin", 330, 1, 0.30303030303030304, 5.915151515151514, 3, 34, 5.0, 7.0, 9.0, 18.829999999999984, 5.5910407807126035, 3.8970176350744623, 2.151190664020805], "isController": false}, {"data": ["DELETE Sejour", 329, 0, 0.0, 8.942249240121583, 6, 55, 8.0, 11.0, 14.0, 41.69999999999976, 5.595142939745923, 1.8140502499957483, 2.2675628124946856], "isController": false}, {"data": ["POST Create Service", 333, 0, 0.0, 8.261261261261264, 5, 143, 7.0, 10.600000000000023, 12.0, 14.0, 5.580039211086349, 3.1333227991939943, 3.438481193550279], "isController": false}, {"data": ["POST Create Patient", 333, 0, 0.0, 8.309309309309299, 5, 83, 7.0, 10.0, 11.0, 20.980000000000075, 5.591376183759823, 3.5819753677211366, 3.8386107980304254], "isController": false}]}, function(index, item){
        switch(index){
            // Errors pct
            case 3:
                item = item.toFixed(2) + '%';
                break;
            // Mean
            case 4:
            // Mean
            case 7:
            // Median
            case 8:
            // Percentile 1
            case 9:
            // Percentile 2
            case 10:
            // Percentile 3
            case 11:
            // Throughput
            case 12:
            // Kbytes/s
            case 13:
            // Sent Kbytes/s
                item = item.toFixed(2);
                break;
        }
        return item;
    }, [[0, 0]], 0, summaryTableHeader);

    // Create error table
    createTable($("#errorsTable"), {"supportsControllersDiscrimination": false, "titles": ["Type of error", "Number of errors", "% in errors", "% in all samples"], "items": [{"data": ["500", 3, 100.0, 0.06981615080288574], "isController": false}]}, function(index, item){
        switch(index){
            case 2:
            case 3:
                item = item.toFixed(2) + '%';
                break;
        }
        return item;
    }, [[1, 1]]);

        // Create top5 errors by sampler
    createTable($("#top5ErrorsBySamplerTable"), {"supportsControllersDiscrimination": false, "overall": {"data": ["Total", 4297, 3, "500", 3, "", "", "", "", "", "", "", ""], "isController": false}, "titles": ["Sample", "#Samples", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors", "Error", "#Errors"], "items": [{"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": ["DELETE Medecin", 329, 1, "500", 1, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": ["POST Create Medecin", 332, 1, "500", 1, "", "", "", "", "", "", "", ""], "isController": false}, {"data": ["GET Medecin", 330, 1, "500", 1, "", "", "", "", "", "", "", ""], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}, {"data": [], "isController": false}]}, function(index, item){
        return item;
    }, [[0, 0]], 0);

});

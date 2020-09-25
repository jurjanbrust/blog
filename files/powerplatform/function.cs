using System;
using System.IO;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using System.Linq;
using System.Collections.Generic;

/// <summary>
/// This azure function converts an Exel file into a HTML file using a template file: see '\\files\\template.html'
/// If the output of the html file is basic, this is a fast method to do the conversion. Another
/// nice option would be to use https://html-agility-pack.net/ for example.
/// </summary>
namespace Function.Convert
{
    public static class Function
    {
        [FunctionName("Function")]
        public static async System.Threading.Tasks.Task RunAsync(
            [BlobTrigger("input/{name}", Connection = "AzureWebJobsStorage")] Stream myBlob,
            string name,
            ILogger log,
            ExecutionContext executionContext,
            IBinder binder)
        {
            log.LogInformation($"C# Blob trigger function Processed blob\n Name:{name} \n Size: {myBlob.Length} Bytes");

            // this is a method to get files loaded into the program, since resource-files cannot be loaded using reflection. 
            // make sure the template.html is set to : 'copy Always' in the file properties.
            string fileName = $"{ Directory.GetParent(executionContext.FunctionDirectory).FullName}\\files\\template.html";
            string htmlTemplate = File.ReadAllText(fileName);

            using SpreadsheetDocument doc = SpreadsheetDocument.Open(myBlob, false);
            WorkbookPart workbookPart = doc.WorkbookPart;
            SharedStringTablePart sstpart = workbookPart.GetPartsOfType<SharedStringTablePart>().First();
            SharedStringTable sst = sstpart.SharedStringTable;

            WorksheetPart worksheetPart = workbookPart.WorksheetParts.First();
            Worksheet sheet = worksheetPart.Worksheet;

            var rows = sheet.Descendants<Row>();
            var cells = sheet.Descendants<Cell>();
            Console.WriteLine(string.Format("Row count = {0}", rows.LongCount()));
            Console.WriteLine(string.Format("Cell count = {0}", cells.LongCount()));

            var header = new Dictionary<string, string>();
            var body = new Dictionary<string, string>();

            foreach (Row row in rows)
            {
                // first row contains header
                if (row.RowIndex == 1)
                {
                    header = ExcelRow(sst, row);
                }
                else if (row.RowIndex == 2)
                {
                    // in this example we only process one row, there can me more ofcourse
                    body = ExcelRow(sst, row);
                }
            }

            string html = "";
            foreach (var item in body)
            {
                html += @"<tr>" +
                        "<td>" + header[item.Key] + "</td>" +
                        "<td>" + item.Value + "</td>" +
                        "</tr>";

            }

            htmlTemplate = htmlTemplate.Replace("{data}", html);
            name = name.Split(".")[0];
            var outputBlob = await binder.BindAsync<TextWriter>(
                                    new BlobAttribute($"output/{name}.html")
                                    {
                                        Connection = "AzureWebJobsStorage"
                                    }
                             );
            outputBlob.WriteLine(htmlTemplate);
        }

        private static Dictionary<string, string> ExcelRow(SharedStringTable sst, Row row)
        {
            var result = new Dictionary<string, string>();
            foreach (Cell cell in row.Descendants<Cell>())
            {
                if ((cell.DataType != null) && (cell.DataType == CellValues.SharedString))
                {
                    int ssid = int.Parse(cell.CellValue.Text);
                    string input = cell.CellReference.Value;
                    string cellRef = new String(input.Where(c => c != '-' && (c < '0' || c > '9')).ToArray());
                    string str = sst.ChildElements[ssid].InnerText;
                    result.Add(cellRef, str);
                }
            }
            return result;
        }
    }
}

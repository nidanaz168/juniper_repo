$(document).ready(function() {
            var grid1 = $('#myTable');
            var grid2 = $('#myTable2');
            var grid3 = $('#myTable3');
            var options1 = {
                filteringRows: function(filterStates) {
                    grid1.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid1.removeClass('filtering');
                    setRowCountOnGrid1();
                }
            };
            var options2 = {
                filteringRows: function(filterStates) {
                    grid2.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid2.removeClass('filtering');
                    setRowCountOnGrid2();
                }
            };
            var options3 = {
                filteringRows: function(filterStates) {
                    grid3.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid3.removeClass('filtering');
                    setRowCountOnGrid3();
                }
            };
            function setRowCountOnGrid1() {
                var rowcount = grid1.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid1.find('tbody tr').length;
                $('#rowcount').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }
            function setRowCountOnGrid2() {
                var rowcount = grid2.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid2.find('tbody tr').length;
                $('#rowcount1').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }
            function setRowCountOnGrid3() {
                var rowcount = grid3.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid3.find('tbody tr').length;
                $('#rowcount2').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }

            grid1.tableFilter(options1); // No additional filters
            grid2.tableFilter(options2); // No additional filters
            grid3.tableFilter(options3); // No additional filters
            setRowCountOnGrid1();
            setRowCountOnGrid2();
            setRowCountOnGrid3();
        });
function filter_init()
{
            var grid1 = $('#myTable');
            var grid2 = $('#myTable2');
            var grid3 = $('#myTable3');
            var options1 = {
                filteringRows: function(filterStates) {
                    grid1.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid1.removeClass('filtering');
                    setRowCountOnGrid1();
                }
            };
            var options2 = {
                filteringRows: function(filterStates) {
                    grid2.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid2.removeClass('filtering');
                    setRowCountOnGrid2();
                }
            };
            var options3 = {
                filteringRows: function(filterStates) {
                    grid3.addClass('filtering');
                },
                filteredRows: function(filterStates) {
                    grid3.removeClass('filtering');
                    setRowCountOnGrid3();
                }
            };
            function setRowCountOnGrid1() {
                var rowcount = grid1.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid1.find('tbody tr').length;
                $('#rowcount').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }
            function setRowCountOnGrid2() {
                var rowcount = grid2.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid2.find('tbody tr').length;
                $('#rowcount1').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }
            function setRowCountOnGrid3() {
                var rowcount = grid3.find('tbody tr:not(:hidden)').length;
                var totcount1 = grid3.find('tbody tr').length;
                $('#rowcount2').text('(Rows ' + rowcount +' of '+totcount1+ ')');
            }

            grid1.tableFilter(options1); // No additional filters
            grid2.tableFilter(options2); // No additional filters
            grid3.tableFilter(options3); // No additional filters
            setRowCountOnGrid1();
            setRowCountOnGrid2();
            setRowCountOnGrid3();
}

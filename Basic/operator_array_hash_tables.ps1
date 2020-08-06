#Operator
# About Operators - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?view=powershell-7
1 -eq 2 #False
1,2,3 -contains 3 # True
"Show me the money" -like "*me*" # True

#compare two arraies
#About Arrays : https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7
#About If : https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_if?view=powershell-7
$listA = @('test1','test2','test3','test6')
$listB = @('test1','test4','test5','test6')
$intersection = @()

$listA | ForEach-Object { 
    if($listB -contains $_){
        $intersection += $_
    }
}
$listB[1] # "test4"
$intersection # "test1","test6"

#hashtable (equivalent to dictionary in Python)
# About Hash Tables - https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7
$dicA = @{}
$dicA['first']=1
$dicA['second']=2
$dicA
$dicB = @{'third'=3;'fourth'=4}
$dicB['third'] # 3

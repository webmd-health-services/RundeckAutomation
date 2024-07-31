# Cleanup from previous tests
$existingProjects = Get-RundeckProject -Filter '*'
foreach ($project in $existingProjects)
{
    Get-RundeckJob -Filter '*' -ProjectName $project.name | Remove-RundeckJob
    Remove-RundeckProject -Name $project.name
}
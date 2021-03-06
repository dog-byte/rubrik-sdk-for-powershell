Remove-Module -Name 'Rubrik' -ErrorAction 'SilentlyContinue'
Import-Module -Name './Rubrik/Rubrik.psd1' -Force

foreach ( $privateFunctionFilePath in ( Get-ChildItem -Path './Rubrik/Private' | Where-Object extension -eq '.ps1').FullName  ) {
    . $privateFunctionFilePath
}

Describe -Name 'Public/Update-RubrikVCD' -Tag 'Public', 'Update-RubrikVCD' -Fixture {
    #region init
    $global:rubrikConnection = @{
        id      = 'test-id'
        userId  = 'test-userId'
        token   = 'test-token'
        server  = 'test-server'
        header  = @{ 'Authorization' = 'Bearer test-authorization' }
        time    = (Get-Date)
        api     = 'v1'
        version = '4.0.5'
    }
    #endregion

    Context -Name 'Request Succeeds' {
        Mock -CommandName Test-RubrikConnection -Verifiable -ModuleName 'Rubrik' -MockWith {}
        Mock -CommandName Submit-Request -Verifiable -ModuleName 'Rubrik' -MockWith {
            @{ 
                'id'        = 'VCD_REFRESH_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0'
                'status'    = 'QUEUED'
                'progress'  = '0'
            }
        }
        It -Name 'Should return QUEUED status' -Test {
            ( Update-RubrikVCD -id 'VCD_REFRESH_01234567-8910-1abc-d435-0abc1234d567_01234567-8910-1abc-d435-0abc1234d567:::0').status |
                Should -BeExactly 'QUEUED'
        }
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Test-RubrikConnection -ModuleName 'Rubrik' -Times 1
        Assert-MockCalled -CommandName Submit-Request -ModuleName 'Rubrik' -Times 1
    }
    Context -Name 'Parameter Validation' {
        It -Name 'Parameter ID cannot be null' -Test {
           { Update-RubrikVCD -id $null } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        } 
        It -Name 'Parameter ID cannot be empty' -Test {
            { Update-RubrikVCD -id '' } |
                Should -Throw "Cannot validate argument on parameter 'id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
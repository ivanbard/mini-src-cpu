param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'addi_tb','andi_tb','brmi_tb','brnz_tb','brpl_tb','brzr_tb',
        'brmi_fail_tb','brnz_fail_tb','brpl_fail_tb','brzr_fail_tb',
        'in_tb','jal_tb','jr_tb','ld_case1_tb','ld_case2_tb',
        'ldi_case3_tb','ldi_case4_tb','mfhi_tb','mflo_tb','ori_tb',
        'out_tb','st_case1_tb','st_case2_tb'
    )]
    [string]$Test,

    [switch]$NoCompile,
    [switch]$NoRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

$tbFile = ".\\simulation\\P2\\$Test.v"
$simOut = ".\\other\\$Test"
$vcdFile = ".\\$Test.vcd"
$gtkwFile = ".\\output\\P2\\$Test.gtkw"

if (-not (Test-Path $tbFile)) {
    throw "Testbench file not found: $tbFile"
}

if (-not (Test-Path '.\\output\\P2')) {
    New-Item -ItemType Directory -Path '.\\output\\P2' | Out-Null
}

if (-not $NoCompile) {
    & iverilog -g2012 -o $simOut -f project.f $tbFile
    if ($LASTEXITCODE -ne 0) {
        throw "iverilog compile failed for $Test"
    }
}

if (-not $NoRun) {
    & vvp $simOut
    if ($LASTEXITCODE -ne 0) {
        throw "vvp run failed for $Test"
    }
}

$commonSignals = @(
    "$Test.clk",
    "$Test.reset",
    "$Test.Present_state[4:0]",
    "$Test.bus_sel[4:0]",
    "$Test.alu_op[4:0]",
    "$Test.Read",
    "$Test.ram_in",
    "$Test.MDRin",
    "$Test.mar_in",
    "$Test.ir_in",
    "$Test.Zin",
    "$Test.Gra",
    "$Test.Grb",
    "$Test.Grc",
    "$Test.Rin",
    "$Test.Rout",
    "$Test.BAout",
    "$Test.Cout",
    "$Test.con_en",
    "$Test.BusMuxOut[31:0]",
    "$Test.pc_val[31:0]",
    "$Test.ir_val[31:0]",
    "$Test.mar_val[31:0]",
    "$Test.Mdataout[31:0]",
    "$Test.zlow_out[31:0]",
    "$Test.con"
)

$proofMap = @{
    'ld_case1_tb'  = @("$Test.DUT.rf.r7_out[31:0]", "$Test.DUT.ram_inst.mem[101][31:0]")
    'ld_case2_tb'  = @("$Test.DUT.rf.r0_out[31:0]", "$Test.DUT.rf.r2_out[31:0]", "$Test.DUT.ram_inst.mem[201][31:0]")
    'ldi_case3_tb' = @("$Test.DUT.rf.r7_out[31:0]")
    'ldi_case4_tb' = @("$Test.DUT.rf.r0_out[31:0]", "$Test.DUT.rf.r2_out[31:0]")
    'st_case1_tb'  = @("$Test.DUT.rf.r6_out[31:0]", "$Test.DUT.ram_inst.mem[31][31:0]")
    'st_case2_tb'  = @("$Test.DUT.rf.r6_out[31:0]", "$Test.DUT.ram_inst.mem[130][31:0]")
    'addi_tb'      = @("$Test.DUT.rf.r4_out[31:0]", "$Test.DUT.rf.r7_out[31:0]", "$Test.DUT.c_extended[31:0]")
    'andi_tb'      = @("$Test.DUT.rf.r4_out[31:0]", "$Test.DUT.rf.r7_out[31:0]")
    'ori_tb'       = @("$Test.DUT.rf.r4_out[31:0]", "$Test.DUT.rf.r7_out[31:0]")
    'brzr_tb'      = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brnz_tb'      = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brpl_tb'      = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brmi_tb'      = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brzr_fail_tb' = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brnz_fail_tb' = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brpl_fail_tb' = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'brmi_fail_tb' = @("$Test.DUT.rf.r3_out[31:0]", "$Test.con", "$Test.pc_val[31:0]")
    'jr_tb'        = @("$Test.DUT.rf.r12_out[31:0]", "$Test.mar_val[31:0]", "$Test.pc_val[31:0]")
    'jal_tb'       = @("$Test.DUT.rf.r4_out[31:0]", "$Test.DUT.rf.r12_out[31:0]", "$Test.pc_val[31:0]")
    'mfhi_tb'      = @("$Test.DUT.hi_val[31:0]", "$Test.DUT.rf.r5_out[31:0]")
    'mflo_tb'      = @("$Test.DUT.lo_val[31:0]", "$Test.DUT.rf.r1_out[31:0]")
    'in_tb'        = @("$Test.device_in[31:0]", "$Test.DUT.inport_inst.inport_val[31:0]", "$Test.DUT.rf.r5_out[31:0]")
    'out_tb'       = @("$Test.DUT.rf.r7_out[31:0]", "$Test.outport_val[31:0]", "$Test.outport_in")
}

$proofSignals = @()
if ($proofMap.ContainsKey($Test)) {
    $proofSignals = $proofMap[$Test]
}

$lines = @(
    '[*]',
    "[*] GTKWave Save File - $Test",
    '[*]',
    "[dumpfile] `"$Test.vcd`"",
    "[savefile] `"$Test.gtkw`"",
    '[timestart] 0',
    '[size] 1920 1080',
    '[pos] -1 -1',
    '*-16.000000 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1',
    "[treeopen] $Test.",
    "[treeopen] $Test.DUT.",
    '[sst_width] 280',
    '[signals_width] 320',
    '[sst_expanded] 1',
    '[sst_vpaned_height] 300',
    '@28'
)

$lines += $commonSignals

if ($proofSignals.Count -gt 0) {
    $lines += '@22'
    $lines += $proofSignals
}

$lines += @('[pattern_trace] 1', '[pattern_trace] 0')

Set-Content -Path $gtkwFile -Value $lines -Encoding ASCII

if (-not (Test-Path $vcdFile)) {
    throw "VCD file not found after run: $vcdFile"
}

Write-Host "Launching GTKWave for $Test"
Write-Host "  VCD : $vcdFile"
Write-Host "  GTKW: $gtkwFile"

& gtkwave $vcdFile $gtkwFile
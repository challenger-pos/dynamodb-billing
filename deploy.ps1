# Deploy DynamoDB Billing - Multi-Environment
# Usage: .\deploy.ps1 -Environment <dev|homologation|production>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "homologation", "production")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DynamoDB Billing Infrastructure Deploy" -ForegroundColor Cyan
Write-Host "  Environment: $Environment" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to environment directory
$envPath = "envs\$Environment"

if (-not (Test-Path $envPath)) {
    Write-Host "❌ Environment directory not found: $envPath" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Navigating to: $envPath" -ForegroundColor Green
Set-Location $envPath

# Step 1: Terraform Init
Write-Host ""
Write-Host "🔧 Step 1: Initializing Terraform..." -ForegroundColor Cyan
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform init failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Terraform initialized successfully" -ForegroundColor Green

# Step 2: Terraform Validate
Write-Host ""
Write-Host "🔍 Step 2: Validating configuration..." -ForegroundColor Cyan
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform validation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Configuration validated successfully" -ForegroundColor Green

# Step 3: Terraform Plan
Write-Host ""
Write-Host "📋 Step 3: Planning changes..." -ForegroundColor Cyan
terraform plan -var-file=terraform.tfvars -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform plan failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Plan generated successfully" -ForegroundColor Green

# Step 4: Confirmation
Write-Host ""
Write-Host "⚠️  Review the plan above." -ForegroundColor Yellow
Write-Host ""
$confirmation = Read-Host "Do you want to apply these changes? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "❌ Deployment cancelled by user" -ForegroundColor Yellow
    Remove-Item tfplan -ErrorAction SilentlyContinue
    exit 0
}

# Step 5: Terraform Apply
Write-Host ""
Write-Host "🚀 Step 5: Applying changes..." -ForegroundColor Cyan
terraform apply tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Terraform apply failed!" -ForegroundColor Red
    Remove-Item tfplan -ErrorAction SilentlyContinue
    exit 1
}

# Cleanup
Remove-Item tfplan -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  ✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Step 6: Show Outputs
Write-Host "📊 Terraform Outputs:" -ForegroundColor Cyan
terraform output

Write-Host ""
Write-Host "💡 Table Name: " -NoNewline -ForegroundColor Cyan
terraform output -raw table_name

Write-Host ""
Write-Host ""
Write-Host "🎉 DynamoDB table for $Environment is ready!" -ForegroundColor Green
Write-Host ""

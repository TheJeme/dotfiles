# PowerToys backup

`backup/` is the checked-in export target for selected PowerToys settings.

Use:

```powershell
pwsh -ExecutionPolicy Bypass -File .\windows\configure-windows.ps1 -ExportPowerToys
```

Then commit the resulting files you actually want to keep.

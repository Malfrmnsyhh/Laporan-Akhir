# RESOURCES CODE

Bab ini mendokumentasikan arsitektur perutean (*routing*) serta cuplikan kode sumber inti modul *Data Center Operations* yang diambil secara langsung dari repositori publik sisi peladen (*MSDCBackend-module-dc-ops*) dan sisi klien (*MSDCFrontend-module-dc-ops*). Seluruh potongan kode di bawah ini berasal murni dari direktori *Modules/DataCenterOps/* dan *src/modules/data-center-ops/* untuk merepresentasikan logika bisnis, proteksi keamanan, dan komponen antarmuka yang menjadi kebaruan perangkat lunak.

## Jalur Akses Aplikasi (Routing Backend dan Frontend)

Arsitektur perutean menghubungkan halaman *Single Page Application* (SPA) React di peramban dengan pengendali *RESTful API* Laravel melalui lapisan autentikasi *OAuth2* (*auth:api*), pemeriksaan izin granular (*permission*), pembatasan laju permintaan (*throttle*), serta rute khusus mesin ke mesin sensor IoT (*api-key*) dan rute pendaftaran tamu publik.

### Perutean API Backend (*Modules/DataCenterOps/routes/api.php*)

```php
<?php

use Illuminate\Support\Facades\Route;
use Modules\DataCenterOps\Entities\SiteRoom;
use Modules\DataCenterOps\Http\Controllers\Api\V1\CctvCameraController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\CrossConnectController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\DashboardController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\DeviceController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\IpamController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\MonitoringController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\NetworkController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\OtbController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\PublicVisitorPassController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\RackController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\RoomController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\SiteController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\TicketController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\UsageRecordController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\VisitorPassController;
use Modules\DataCenterOps\Http\Controllers\Api\V1\WorkOrderController;

Route::model('siteRoom', SiteRoom::class);

Route::prefix('v1/data-center-ops')
    ->middleware(['auth:api', 'core.active'])
    ->group(function () {

    // Dashboard Summary (KPI) & Jadwal Piket
    Route::middleware('permission:dashboard.view')->group(function () {
        Route::get('dashboard/summary', [DashboardController::class, 'summary']);
        Route::get('dashboard/details', [DashboardController::class, 'details']);
        Route::get('dashboard/on-duty-today', [DashboardController::class, 'onDutyToday']);
    });

    // Klaster 1: Site, Room, dan Rack 42U
    Route::middleware('permission:site.view')->group(function () {
        Route::get('sites', [SiteController::class, 'index']);
        Route::get('sites/{site}', [SiteController::class, 'show']);
        Route::get('rooms', [RoomController::class, 'index']);
    });
    Route::middleware('permission:site.manage')->group(function () {
        Route::post('sites', [SiteController::class, 'store']);
        Route::put('sites/{site}', [SiteController::class, 'update']);
        Route::delete('sites/{site}', [SiteController::class, 'destroy']);
        Route::post('sites/{site}/rooms', [SiteController::class, 'storeRoom']);
        Route::delete('sites/{site}/rooms/{siteRoom}', [SiteController::class, 'deleteRoom']);
    });

    Route::middleware('permission:rack.view')->group(function () {
        Route::get('racks', [RackController::class, 'index']);
        Route::get('racks/{rack}', [RackController::class, 'show']);
        Route::get('racks/{rack}/utilization', [RackController::class, 'utilization']);
        Route::get('racks/{rack}/occupancy', [RackController::class, 'occupancy']);
    });
    Route::middleware('permission:rack.manage')->group(function () {
        Route::post('racks', [RackController::class, 'store']);
        Route::post('racks/{rack}/allocate', [RackController::class, 'allocate']);
        Route::post('rack-allocations/{allocation}/release', [RackController::class, 'release']);
        Route::post('rack-allocations/{allocation}/request-release', [RackController::class, 'requestRelease']);
        Route::delete('racks/{rack}', [RackController::class, 'destroy']);
    });

    // Klaster 2: Device, Network Port, Cross-Connect, OTB, dan IPAM
    Route::middleware('permission:device.manage')->group(function () {
        Route::post('devices', [DeviceController::class, 'store']);
        Route::put('devices/{device}', [DeviceController::class, 'update']);
        Route::post('devices/{device}/move', [DeviceController::class, 'move']);
        Route::delete('devices/{device}', [DeviceController::class, 'destroy']);
    });
    Route::middleware('permission:network.view')->group(function () {
        Route::get('ports', [NetworkController::class, 'portAllIndex']);
        Route::get('devices/{device}/ports', [NetworkController::class, 'portIndex']);
    });
    Route::middleware('permission:network.manage')->group(function () {
        Route::post('devices/{device}/ports', [NetworkController::class, 'portStore']);
        Route::put('ports/{port}', [NetworkController::class, 'portUpdate']);
        Route::delete('ports/{port}', [NetworkController::class, 'portDestroy']);
    });
    Route::middleware('permission:cross-connect.manage')->group(function () {
        Route::post('cross-connects', [CrossConnectController::class, 'store']);
        Route::post('cross-connects/{crossConnect}/release', [CrossConnectController::class, 'release']);
        Route::post('cross-connects/{crossConnect}/repair', [CrossConnectController::class, 'repair']);
    });
    Route::middleware('permission:otb.manage')->group(function () {
        Route::post('otbs', [OtbController::class, 'store']);
        Route::post('otb-ports/{port}/allocate', [OtbController::class, 'allocatePort']);
        Route::post('otb-ports/{port}/release', [OtbController::class, 'releasePort']);
    });
    Route::middleware('permission:ipam.manage')->group(function () {
        Route::post('ip-subnets', [IpamController::class, 'subnetStore']);
        Route::delete('ip-subnets/{subnet}', [IpamController::class, 'subnetDestroy']);
        Route::post('ip-subnets/{subnet}/generate-addresses', [IpamController::class, 'generateAddresses']);
        Route::post('ip-addresses/{ipAddress}/allocate', [IpamController::class, 'allocate']);
    });

    // Klaster 3: Telemetri Lingkungan ASHRAE TC 9.9 dan Pengawasan CCTV
    Route::middleware('permission:power-cooling.view')->group(function () {
        Route::get('metric-readings', [MonitoringController::class, 'readingIndex']);
        Route::get('monitoring/racks/telemetry-summary', [MonitoringController::class, 'allRacksTelemetrySummary']);
    });
    Route::middleware('permission:monitoring.manage')->group(function () {
        Route::post('monitoring-thresholds', [MonitoringController::class, 'thresholdStore']);
        Route::post('alarms/{alarm}/acknowledge', [MonitoringController::class, 'alarmAcknowledge']);
        Route::post('alarms/{alarm}/resolve', [MonitoringController::class, 'alarmResolve']);
    });
    Route::middleware('permission:cctv.manage')->group(function () {
        Route::post('cctv-cameras/test', [CctvCameraController::class, 'test'])
            ->middleware('throttle:10,1,cctv-probe');
        Route::post('cctv-cameras/{id}/check', [CctvCameraController::class, 'check'])
            ->whereNumber('id')->middleware('throttle:10,1,cctv-probe');
        Route::post('cctv-cameras', [CctvCameraController::class, 'store'])
            ->middleware('throttle:20,1,cctv-save');
    });

    // Klaster 4: Ticket, Work Order, dan Usage Billing
    Route::middleware('permission:ticket.manage')->group(function () {
        Route::post('tickets', [TicketController::class, 'store']);
        Route::post('tickets/{ticket}/activities', [TicketController::class, 'logActivity']);
        Route::post('tickets/{ticket}/status', [TicketController::class, 'updateStatus']);
    });
    Route::middleware('permission:work-order.manage')->group(function () {
        Route::post('work-order-items/{workOrderItem}/toggle', [WorkOrderController::class, 'toggleItem']);
    });
    Route::middleware('permission:usage-record.manage')->group(function () {
        Route::post('usage-records/generate', [UsageRecordController::class, 'generate']);
        Route::post('usage-records/{usageRecord}/bill-remote-hands', [UsageRecordController::class, 'billRemoteHands']);
    });

    // Klaster 5: Visitor Pass & Scanner Pos Jaga ISO/IEC 27001
    Route::middleware('permission:visitor-pass.manage')->group(function () {
        Route::post('visitor-passes/invite', [VisitorPassController::class, 'invite']);
        Route::post('visitor-passes', [VisitorPassController::class, 'store']);
        Route::post('visitor-passes/scan-verify', [VisitorPassController::class, 'scanVerify']);
        Route::post('visitor-passes/{id}/approve', [VisitorPassController::class, 'approve']);
        Route::post('visitor-passes/{id}/check-out', [VisitorPassController::class, 'checkOut']);
    });
});

// Jalur Ingest Sensor IoT (Proteksi X-API-Key & IP Whitelist)
Route::prefix('v1/data-center-ops')->middleware(['api-key'])->group(function () {
    Route::post('iot/metric-readings', [MonitoringController::class, 'iotRecordReading']);
});

// Jalur Publik Pendaftaran Mandiri & Kartu E-Badge QR (Tanpa Login ERP)
Route::prefix('v1/public')->group(function () {
    Route::get('visitor-invitation/{token}', [PublicVisitorPassController::class, 'showInvitation']);
    Route::post('visitor-invitation/{token}/register', [PublicVisitorPassController::class, 'submitRegistration']);
    Route::get('visitor-pass/{publicUrlToken}', [PublicVisitorPassController::class, 'show']);
});
```

### Pendaftaran Rute SPA Frontend (*src/modules/data-center-ops/routes.tsx*)

```tsx
import type { RouteObject } from "react-router-dom";
import { SiteListPage } from "./pages/SiteListPage";
import { SiteDetailPage } from "./pages/SiteDetailPage";
import { RoomListPage } from "./pages/RoomListPage";
import { RackListPage } from "./pages/RackListPage";
import { RackDetailPage } from "./pages/RackDetailPage";
import { RackMonitoringPage } from "./pages/RackMonitoringPage";
import { RackMonitoringDashboardPage } from "./pages/RackMonitoringDashboardPage";
import { DeviceListPage } from "./pages/DeviceListPage";
import { DeviceDetailPage } from "./pages/DeviceDetailPage";
import { NetworkPortListPage } from "./pages/NetworkPortListPage";
import { TicketListPage } from "./pages/TicketListPage";
import { TicketDetailPage } from "./pages/TicketDetailPage";
import { UsageListPage } from "./pages/UsageListPage";
import { IpamListPage } from "./pages/IpamListPage";
import { IpSubnetDetailPage } from "./pages/IpSubnetDetailPage";
import { DashboardPage } from "./pages/DashboardPage";
import { CrossConnectListPage } from "./pages/CrossConnectListPage";
import { OtbListPage } from "./pages/OtbListPage";
import { OtbDetailPage } from "./pages/OtbDetailPage";
import { SuratDcOpsPage } from "./pages/SuratDcOpsPage";
import { SuratDcOpsCreatePage } from "./pages/SuratDcOpsCreatePage";
import { SuratDcOpsDetailPage } from "./pages/SuratDcOpsDetailPage";
import { WorkOrderListPage } from "./pages/WorkOrderListPage";
import { WorkOrderDetailPage } from "./pages/WorkOrderDetailPage";
import { VisitorPassListPage } from "./pages/VisitorPassListPage";
import { VisitorPassDetailPage } from "./pages/VisitorPassDetailPage";
import { VisitorPassScannerPage } from "./pages/VisitorPassScannerPage";
import { VisitorPassInvitePage } from "./pages/VisitorPassInvitePage";
import { VisitorPassCreatePage } from "./pages/VisitorPassCreatePage";
import { CctvListPage } from "./pages/CctvListPage";
import { CctvFormPage } from "./pages/CctvFormPage";

export const dataCenterOpsRoutes: RouteObject[] = [
  { path: "dc", element: <DashboardPage /> },
  { path: "dc/sites", element: <SiteListPage /> },
  { path: "dc/sites/:id", element: <SiteDetailPage /> },
  { path: "dc/rooms", element: <RoomListPage /> },
  { path: "dc/racks", element: <RackListPage /> },
  { path: "dc/racks/:id", element: <RackDetailPage /> },
  { path: "dc/monitoring", element: <RackMonitoringPage /> },
  { path: "dc/monitoring/overview", element: <RackMonitoringDashboardPage /> },
  { path: "dc/monitoring-racks", element: <RackMonitoringDashboardPage /> },
  { path: "dc/devices", element: <DeviceListPage /> },
  { path: "dc/devices/:id", element: <DeviceDetailPage /> },
  { path: "dc/network-ports", element: <NetworkPortListPage /> },
  { path: "dc/cross-connects", element: <CrossConnectListPage /> },
  { path: "dc/otbs", element: <OtbListPage /> },
  { path: "dc/otbs/:id", element: <OtbDetailPage /> },
  { path: "dc/tickets", element: <TicketListPage /> },
  { path: "dc/tickets/:id", element: <TicketDetailPage /> },
  { path: "dc/work-orders", element: <WorkOrderListPage /> },
  { path: "dc/work-orders/:id", element: <WorkOrderDetailPage /> },
  { path: "dc/usage", element: <UsageListPage /> },
  { path: "dc/ipam", element: <IpamListPage /> },
  { path: "dc/ipam/:id", element: <IpSubnetDetailPage /> },
  { path: "dc/surat", element: <SuratDcOpsPage /> },
  { path: "dc/surat/create", element: <SuratDcOpsCreatePage /> },
  { path: "dc/surat/:id", element: <SuratDcOpsDetailPage /> },
  { path: "dc/visitor-passes", element: <VisitorPassListPage /> },
  { path: "dc/visitor-passes/invite", element: <VisitorPassInvitePage /> },
  { path: "dc/visitor-passes/create", element: <VisitorPassCreatePage /> },
  { path: "dc/visitor-passes/:id", element: <VisitorPassDetailPage /> },
  { path: "dc/visitor-scanner", element: <VisitorPassScannerPage /> },
  { path: "dc/cctv", element: <CctvListPage /> },
  { path: "dc/cctv/new", element: <CctvFormPage /> },
  { path: "dc/cctv/:id/edit", element: <CctvFormPage /> },
];
```

## Implementasi Fitur Utama (Domain Service dan Komponen Kunci)

Bagian ini menampilkan cuplikan implementasi layanan domain (*Domain Service*) di sisi peladen dan komponen interaktif kunci di sisi klien yang menopang keandalan transaksi, integritas data, dan keamanan operasional modul *Data Center Operations*.

### Alokasi Slot Rak 42U dengan *Pessimistic Locking* dan *Delete Guard* (*RackService.php*)

```php
<?php

namespace Modules\DataCenterOps\Services;

use Illuminate\Support\Facades\DB;
use Modules\DataCenterOps\Entities\Device;
use Modules\DataCenterOps\Entities\Rack;
use Modules\DataCenterOps\Entities\RackAllocation;
use Modules\DataCenterOps\Models\Traits\HasOrganizationScope;

class RackService
{
    public function deleteRack(Rack $rack): void
    {
        if ($rack->allocations()->activeOrReserved()->exists()) {
            throw new \RuntimeException(
                "Rack '{$rack->rack_code}' masih punya alokasi customer aktif - " .
                "lepas dulu alokasinya sebelum dihapus."
            );
        }
        if (Device::where('rack_id', $rack->id)->exists()) {
            throw new \RuntimeException(
                "Rack '{$rack->rack_code}' masih punya device terpasang - " .
                "pindahkan/hapus device dulu."
            );
        }

        $rack->delete();
    }

    public function allocate(Rack $rack, array $data): RackAllocation
    {
        $startU = (int) $data['start_u'];
        $endU = (int) $data['end_u'];

        if ($startU < 1 || $endU > $rack->total_u || $startU > $endU) {
            throw new \InvalidArgumentException(
                "Rentang U {$startU}-{$endU} tidak valid untuk rack {$rack->total_u}U."
            );
        }

        $this->assertContractNotLocked($data['contract_id'] ?? null);

        return DB::transaction(function () use ($rack, $data, $startU, $endU) {
            $overlap = $rack->allocations()
                ->whereIn('status', ['active', 'reserved'])
                ->where('start_u', '<=', $endU)
                ->where('end_u', '>=', $startU)
                ->lockForUpdate()
                ->exists();

            if ($overlap) {
                throw new \RuntimeException(
                    "Rentang U {$startU}-{$endU} tumpang tindih dengan alokasi " .
                    "active/reserved lain di rack '{$rack->rack_code}'."
                );
            }

            $orgId = $rack->organization_id ?? HasOrganizationScope::resolveOrganizationId();
            $allocationData = [
                'rack_id'        => $rack->id,
                'start_u'        => $startU,
                'end_u'          => $endU,
                'customer_id'    => $data['customer_id'] ?? null,
                'contract_id'    => $data['contract_id'] ?? null,
                'sales_order_id' => $data['sales_order_id'] ?? null,
                'allocated_date' => $data['allocated_date'] ?? now()->toDateString(),
                'status'         => $data['status'] ?? 'active',
                'notes'          => $data['notes'] ?? null,
            ];

            if ($orgId) {
                $allocationData['organization_id'] = $orgId;
            }

            return $rack->allocations()->create($allocationData);
        });
    }
}
```

### Pengaman Penghapusan Port dan Subnet IPAM (*NetworkService.php* & *IpamService.php*)

```php
// Modules/DataCenterOps/app/Services/NetworkService.php
public function deletePort(NetworkPort $port): void
{
    DB::transaction(function () use ($port) {
        if ($port->connected_to_port_id) {
            NetworkPort::where('id', $port->connected_to_port_id)
                ->update(['connected_to_port_id' => null]);
        }

        NetworkPort::where('connected_to_port_id', $port->id)
            ->update(['connected_to_port_id' => null]);

        $port->delete();
    });
}

// Modules/DataCenterOps/app/Services/IpamService.php
public function deleteSubnet(IpSubnet $subnet): void
{
    $activeIpCount = $subnet->addresses()
        ->whereIn('status', ['allocated', 'reserved'])
        ->count();

    if ($activeIpCount > 0) {
        throw new \RuntimeException(
            "Subnet '{$subnet->cidr}' tidak dapat dihapus karena masih memiliki " .
            "{$activeIpCount} alamat IP yang berstatus 'allocated' atau 'reserved'."
        );
    }

    DB::transaction(function () use ($subnet) {
        $subnet->addresses()->delete();
        $subnet->delete();
    });
}
```

### Evaluasi Ambang Batas Ganda ASHRAE TC 9.9 dan Deduplikasi Alarm (*MonitoringService.php*)

```php
// Modules/DataCenterOps/app/Services/MonitoringService.php
$value = (float) $reading->value;
$severity = null;
$message = null;

// 1. Cek Kritis: dual bounds (bawah kondensasi / atas overheating)
if ($threshold->critical_lower_threshold !== null
    && $value < (float) $threshold->critical_lower_threshold
) {
    $severity = 'critical';
    $message = "Suhu/Kelembapan {$value} di bawah ambang kritis " .
        "(< {$threshold->critical_lower_threshold}). Bahaya kondensasi/ESD.";
} elseif ($threshold->critical_upper_threshold !== null
    && $value > (float) $threshold->critical_upper_threshold
) {
    $severity = 'critical';
    $message = "Suhu/Kelembapan {$value} melebihi ambang kritis " .
        "(> {$threshold->critical_upper_threshold}). Bahaya overheating.";
}

// 2. Cek Peringatan (Warning): jika belum kritis
if (! $severity) {
    if ($threshold->warning_lower_threshold !== null
        && $value < (float) $threshold->warning_lower_threshold
    ) {
        $severity = 'warning';
        $message = "Suhu/Kelembapan {$value} di bawah batas peringatan " .
            "(< {$threshold->warning_lower_threshold}).";
    } elseif ($threshold->warning_upper_threshold !== null
        && $value > (float) $threshold->warning_upper_threshold
    ) {
        $severity = 'warning';
        $message = "Suhu/Kelembapan {$value} melebihi batas peringatan " .
            "(> {$threshold->warning_upper_threshold}).";
    }
}

if (! $severity) {
    return;
}

// 3. Deduplikasi: cegah alarm storm bila alarm open sudah ada
$alreadyOpenQuery = Alarm::withoutGlobalScope('organization')
    ->open()
    ->where('alarm_type', $reading->metric_type . '_threshold');
$alreadyOpenQuery = $reading->rack_id
    ? $alreadyOpenQuery->where('rack_id', $reading->rack_id)
    : $alreadyOpenQuery->whereNull('rack_id');

if ($alreadyOpenQuery->exists()) {
    return;
}
```

### Proteksi *Anti-SSRF* Pemeriksaan Aliran CCTV (*CctvStreamProbeService.php*)

```php
// Modules/DataCenterOps/app/Services/CctvStreamProbeService.php
public function detectType(string $url): ?string
{
    $parts = parse_url(trim($url));
    if ($parts === false || empty($parts['scheme']) || empty($parts['host'])) {
        return null;
    }

    $scheme = strtolower($parts['scheme']);
    if (in_array($scheme, self::RTMP_SCHEMES, true)) {
        return 'rtmp';
    }

    if (in_array($scheme, self::HLS_SCHEMES, true)
        && str_ends_with(strtolower($parts['path'] ?? ''), '.m3u8')
    ) {
        return 'hls';
    }

    return null;
}

public function assertAllowed(string $url): string
{
    $url = trim($url);

    // Tolak karakter kontrol untuk mencegah injeksi argumen ffprobe
    if ($url === '' || preg_match('/[\s\x00-\x1F\x7F]/', $url)) {
        throw $this->invalidFormat();
    }

    $type = $this->detectType($url);
    if ($type === null) {
        throw $this->invalidFormat();
    }

    $parts = parse_url($url);
    if (isset($parts['user']) || isset($parts['pass'])) {
        throw new CctvStreamUrlRejectedException(
            self::ERROR_INVALID_FORMAT,
            'Alamat stream tidak boleh memuat kredensial user:pass@host.'
        );
    }

    $this->assertHostAllowed($parts['host']);

    return $type;
}
```

### Sinkronisasi *Work Order* dan Penagihan *Remote Hands* (*WorkOrderService.php* & *UsageReportingService.php*)

```php
// Modules/DataCenterOps/app/Services/WorkOrderService.php
private function recomputeContractDates(WorkOrder $workOrder): void
{
    $items = $workOrder->items;
    $contract = Contract::find($workOrder->contract_id);
    if (! $contract) {
        return;
    }

    $serviceItems = $items->where('item_type', 'service');
    $internetItems = $serviceItems->whereIn('service_type', self::INTERNET_SERVICE_TYPES);
    $deviceItems = $serviceItems->reject(
        fn (WorkOrderItem $i) => in_array($i->service_type, self::INTERNET_SERVICE_TYPES, true)
    );
    $testingItem = $items->firstWhere('item_type', 'testing');

    $contract->update([
        'device_installed_at' => ($deviceItems->isNotEmpty()
            && $deviceItems->every(fn ($i) => $i->is_completed))
            ? $deviceItems->max('completed_at') : null,
        'internet_installed_at' => ($internetItems->isNotEmpty()
            && $internetItems->every(fn ($i) => $i->is_completed))
            ? $internetItems->max('completed_at') : null,
        'testing_completed_at' => $testingItem?->is_completed
            ? $testingItem->completed_at : null,
    ]);

    $allDone = $items->isNotEmpty() && $items->every(fn (WorkOrderItem $i) => $i->is_completed);
    $workOrder->update([
        'status'       => $allDone ? 'completed' : 'open',
        'completed_at' => $allDone ? now() : null,
    ]);
}

// Modules/DataCenterOps/app/Services/UsageReportingService.php
public function billRemoteHands(
    UsageRecord $record,
    int $revenueAccountId,
    float $ratePerHour,
    ?int $performedBy = null
): UsageRecord {
    if ($record->usage_type !== 'remote_hands') {
        throw new \InvalidArgumentException(
            'billRemoteHands() hanya untuk usage_type remote_hands.'
        );
    }
    if (in_array($record->status, ['sent_to_finance', 'billed'], true)) {
        throw new \RuntimeException(
            'Usage record ini sudah pernah ditagih/dikirim ke Finance sebelumnya.'
        );
    }

    return DB::transaction(function () use ($record, $revenueAccountId, $ratePerHour, $performedBy) {
        $customer = $record->customer;
        $periodLabel = sprintf('%04d-%02d', $record->period_year, $record->period_month);

        $invoice = $this->arService->createInvoice([
            'customer_id'      => $customer->id,
            'customer_name'    => $customer->company_name,
            'due_date'         => now()->addDays(30)->toDateString(),
            'reference_type'   => 'dc_usage_record',
            'reference_number' => "USG-{$record->id}",
            'created_by'       => $performedBy,
            'status'           => 'draft',
            'lines' => [[
                'description'        => "Remote Hands - {$periodLabel} ({$record->quantity} jam)",
                'quantity'           => $record->quantity,
                'unit_price'         => $ratePerHour,
                'revenue_account_id' => $revenueAccountId,
            ]],
        ]);

        $record->update([
            'status'     => 'sent_to_finance',
            'invoice_id' => $invoice->id,
            'sent_at'    => now(),
        ]);

        return $record->fresh();
    });
}
```

### Verifikasi QR Pos Satpam Enam Lapis Anti-Replay (*VisitorPassService.php*)

```php
// Modules/DataCenterOps/app/Services/VisitorPassService.php
public function scanAndVerify(
    string $rawToken,
    string $method,
    int $officerId,
    array $clientMeta = []
): array {
    $attemptedHash = hash('sha256', trim($rawToken));

    try {
        return DB::transaction(function () use ($attemptedHash, $method, $officerId, $clientMeta) {
            $pass = VisitorPass::where('token_hash', $attemptedHash)
                ->lockForUpdate()
                ->first();

            // 1. Cek keberadaan token
            if (! $pass) {
                throw new \DomainException('Kode QR tidak dikenali dalam sistem.');
            }

            $pass->load(['customer', 'contract', 'site', 'room']);

            // 2. Kesesuaian gedung pos jaga
            if ($this->isWrongScanSite($pass, $clientMeta)) {
                $allocatedSite = $pass->site?->site_name ?? "Site ID #{$pass->site_id}";
                throw new \DomainException(
                    "Akses ditolak: Tiket terdaftar untuk {$allocatedSite}."
                );
            }

            // 3. Cek status kontrak CRM & masa berlaku TTL
            if (! $pass->contract || $pass->contract->status !== 'active') {
                throw new \DomainException('Akses ditolak: Kontrak pelanggan tidak aktif.');
            }
            if (now()->lt($pass->valid_from) || now()->gt($pass->valid_until)) {
                throw new \DomainException('Akses ditolak: Di luar jadwal izin masuk.');
            }

            // 4. Anti-Replay Single-Use Protection
            if ($pass->qr_token_consumed_at !== null
                || in_array($pass->status, ['active_in_facility', 'overstayed'])
            ) {
                throw new ReplayAttemptException(
                    'Akses ditolak: Kode QR sudah pernah digunakan (Single-use policy).'
                );
            }

            // 5. Whitelist status ketat: hanya 'scheduled' yang boleh check-in
            if ($pass->status !== 'scheduled') {
                throw new \DomainException(
                    "Akses ditolak: Status tiket '{$pass->status}' bukan scheduled."
                );
            }

            // 6. Access Granted & rekam jejak audit permanen
            $pass->update([
                'status'               => 'active_in_facility',
                'qr_token_consumed_at' => now(),
                'actual_check_in_at'   => now(),
                'check_in_method'      => $method,
                'check_in_officer_id'  => $officerId,
            ]);

            VisitorAccessLog::create([
                'organization_id'      => $pass->organization_id,
                'visitor_pass_id'      => $pass->id,
                'scan_timestamp'       => now(),
                'attempted_token_hash' => $attemptedHash,
                'scan_method'          => $method,
                'officer_id'           => $officerId,
                'ip_address'           => $clientMeta['ip'] ?? null,
                'result'               => 'granted',
                'reason'               => 'Verifikasi QR berhasil. Pengunjung masuk fasilitas.',
            ]);

            return [
                'access_granted' => true,
                'visitor_pass'   => $pass,
            ];
        });
    } catch (ReplayAttemptException $e) {
        $pass = VisitorPass::where('token_hash', $attemptedHash)->first();
        VisitorAccessLog::create([
            'organization_id'      => $pass?->organization_id,
            'visitor_pass_id'      => $pass?->id,
            'scan_timestamp'       => now(),
            'attempted_token_hash' => $attemptedHash,
            'scan_method'          => $method,
            'officer_id'           => $officerId,
            'result'               => 'denied_already_used',
            'reason'               => $e->getMessage(),
        ]);

        throw $e;
    }
}
```

### Komponen Visualisasi Elevasi Rak 42U dan Pemindai QR Pos Jaga (*RackVisualPicker.tsx* & *VisitorScannerView.tsx*)

```tsx
// src/modules/data-center-ops/components/rack/RackVisualPicker.tsx
const selectedRange =
  anchor !== null && rangeEnd !== null
    ? ([Math.min(anchor, rangeEnd), Math.max(anchor, rangeEnd)] as const)
    : null;

const rangeIsValid = (() => {
  if (!selectedRange) return false;
  const minU = Math.min(selectedRange[0], selectedRange[1]);
  const maxU = Math.max(selectedRange[0], selectedRange[1]);

  const targetSlots = occupancy.slots.filter(
    (slot) => slot.u >= minU && slot.u <= maxU
  );

  const expectedCount = maxU - minU + 1;
  return (
    targetSlots.length === expectedCount &&
    targetSlots.every((s) => s.status === "available")
  );
})();

async function handleConfirmLock() {
  if (!selectedRange || !rangeIsValid) return;
  setError(null);
  try {
    const allocation = await allocateMutation.mutateAsync({
      start_u: selectedRange[0],
      end_u: selectedRange[1],
      customer_id: customerId ?? undefined,
      contract_id: contractId ?? undefined,
      sales_order_id: salesOrderId ?? undefined,
      status: allocationStatus,
      notes: notes || undefined,
    });
    onAllocated?.({
      id: allocation.id,
      start_u: selectedRange[0],
      end_u: selectedRange[1],
    });
    resetSelection();
  } catch (err) {
    setError(extractErrorMessage(err));
  }
}
```

```tsx
// src/modules/data-center-ops/components/visitor-scanner/VisitorScannerView.tsx
async function decodeQrFromImage(img: HTMLImageElement): Promise<string | null> {
  // Layer 1: Native HTML5 BarcodeDetector (akselerasi perangkat keras peramban)
  const NativeBarcodeDetector = (
    window as unknown as {
      BarcodeDetector?: new (opts?: { formats: string[] }) => {
        detect: (src: CanvasImageSource) => Promise<Array<{ rawValue: string }>>;
      };
    }
  ).BarcodeDetector;

  if (typeof NativeBarcodeDetector === "function") {
    try {
      const detector = new NativeBarcodeDetector({ formats: ["qr_code"] });
      const results = await detector.detect(img);
      if (results && results.length > 0 && results[0].rawValue) {
        return results[0].rawValue;
      }
    } catch (err) {
      console.warn("BarcodeDetector gagal, beralih ke multi-scale jsQR:", err);
    }
  }

  // Layer 2: Multi-Scale Adaptive Downsampling memakai jsQR
  const tryJsQRAtScale = (maxDim: number): string | null => {
    let w = img.naturalWidth || img.width;
    let h = img.naturalHeight || img.height;
    if (!w || !h) return null;

    if (maxDim > 0 && (w > maxDim || h > maxDim)) {
      if (w > h) {
        h = Math.round((h * maxDim) / w);
        w = maxDim;
      } else {
        w = Math.round((w * maxDim) / h);
        h = maxDim;
      }
    }
    const canvas = document.createElement("canvas");
    canvas.width = w;
    canvas.height = h;
    const ctx = canvas.getContext("2d", { willReadFrequently: true });
    if (!ctx) return null;
    ctx.drawImage(img, 0, 0, w, h);
    const imageData = ctx.getImageData(0, 0, w, h);
    return jsQR(imageData.data, w, h)?.data ?? null;
  };

  for (const scale of [1200, 800, 500]) {
    const decoded = tryJsQRAtScale(scale);
    if (decoded) return decoded;
  }
  return null;
}
```

### Tautan Repositori Kode Sumber Publik (GitHub)

Seluruh kode sumber lengkap modul *Data Center Operations* (*backend* Laravel Modular dan *frontend* React TypeScript) dapat diakses dan ditinjau secara terbuka melalui repositori resmi berikut:

- **Link GitHub Backend:** https://github.com/Malfrmnsyhh/MSDCBackend-module-dc-ops
- **Link GitHub Frontend:** https://github.com/Malfrmnsyhh/MSDCFrontend-module-dc-ops

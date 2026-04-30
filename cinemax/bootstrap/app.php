<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // Sanctum SPA cookie-auth: a /sanctum/csrf-cookie endpointot publikálja,
        // és a "stateful" domainekről jövő API-hívásokat session-eli.
        $middleware->statefulApi();

        // Postman-tesztekhez engedjük csak a header alapú X-Requested-With nélküli
        // login/register/logout-ot, a többi route CSRF-et követel.
        $middleware->validateCsrfTokens(except: [
            'api/user/login', // legacy custom login endpoint
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        // Auth middleware redirect-jeit JSON-os route-okon 401-re fordítjuk,
        // hogy a SPA frontend ne 500-as Route[login]-be fusson.
        $exceptions->render(function (\Illuminate\Auth\AuthenticationException $e, $request) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json(['message' => 'Bejelentkezés szükséges.'], 401);
            }
            return redirect()->guest(route('login'));
        });
    })->create();

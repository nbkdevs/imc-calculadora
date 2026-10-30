<?php

declare(strict_types=1);

namespace ImcCalculadora\Tests;

use ImcCalculadora\Imc;
use PHPUnit\Framework\TestCase;

final class ImcTest extends TestCase
{
    public function testOverweightExample(): void
    {
        $r = Imc::calculate(82, 175);
        $this->assertSame([26.8, 'sobrepeso', 'Sobrepeso', 5.7], [$r['bmi'], $r['key'], $r['label'], $r['diff_kg']]);
        $this->assertStringContainsString('5,7 kg', $r['message']);
    }

    public function testRoundsBeforeClassifying(): void
    {
        $this->assertSame('sobrepeso', Imc::classify(24.96)['key']);
        $this->assertSame('normal', Imc::classify(24.94)['key']);
        $this->assertSame('normal', Imc::classify(18.46)['key']);
        $this->assertSame('obesidad_1', Imc::classify(29.96)['key']);
    }

    public function testWhoClasses(): void
    {
        $keys = array_map(fn ($w) => Imc::calculate($w, 170)['key'], [45, 48, 50, 70, 100, 110, 120]);
        $this->assertSame(['delgadez_severa', 'delgadez_moderada', 'delgadez_leve', 'normal', 'obesidad_1', 'obesidad_2', 'obesidad_3'], $keys);
    }

    public function testRangeAndUnderweight(): void
    {
        $this->assertSame(['min_kg' => 52.2, 'max_kg' => 70.3], Imc::healthyRange(168));
        $r = Imc::calculate(50, 170, 'en');
        $this->assertSame(3.5, $r['diff_kg']);
        $this->assertStringContainsString('3.5 kg below', $r['message']);
    }

    public function testImperialCommaMetresErrors(): void
    {
        $this->assertSame(22.7, Imc::round1(Imc::bmiImperial(154, 69)));
        $this->assertSame(25.0, Imc::calculate('70,5', '1,68')['bmi']);
        $this->expectException(\InvalidArgumentException::class);
        Imc::parseNumber('abc');
    }
}

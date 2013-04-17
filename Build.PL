use Module::Build;

my $build = Module::Build->new(
    module_name    => 'PerlDiver',
    build_requires => {
        'Module::Build' => '0.30',
    },
    requires => {
        'JSON'        => '2.53',
        'LWP::Simple' => '6.00',
        'URI'         => '1.60',
    },
    use_tap_harness  => 1,
    tap_harness_args => {
        lib => 'lib',
    },
);

$build->create_build_script();

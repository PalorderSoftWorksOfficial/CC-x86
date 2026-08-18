local tests = {
    "tests.test_cpu",
    "tests.test_flags",
    "tests.test_decoder",
    "tests.test_conformance",
}

for _, name in ipairs(tests) do
    print("running " .. name)
    dofile(name:gsub("%.", "/") .. ".lua")
end

print("CC:X86 test suite passed")

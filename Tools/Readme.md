



<div class="hex-row">

    <div class="hex-container">
        <button class="copy-button" onclick="copyHex(this)">Copy</button>
        <pre>
01 20 FF 3E 05 CD 12 40
C3 00 00 21 80 D3 36 01
        </pre>
    </div>

    <div class="hex-container">
        <button class="copy-button" onclick="copyHex(this)">Copy</button>
        <pre>
21 80 D3 36 01 CD 12 40
3E 05 C3 00 00 AF 21 80
        </pre>
    </div>

</div>

<style>
.hex-row {
    display: flex;
    gap: 10px;
}

.hex-container {
    position: relative;
    flex: 1;
}

.hex-container pre {
    font-family: monospace;
    margin: 0;
}

.copy-button {
    position: absolute;
    top: 8px;
    right: 8px;
    cursor: pointer;
}

@media (max-width: 700px) {
    .hex-row {
        flex-direction: column;
    }
}
</style>

<script>
function copyHex(button) {
    const pre = button.parentElement.querySelector("pre");

    navigator.clipboard.writeText(pre.textContent.trim()).then(() => {
        button.textContent = "Copied!";
        setTimeout(() => button.textContent = "Copy", 1500);
    });
}
</script>
// Overrides assets/js/mermaid-init.js from fhir.base.template.
//
// The base template initialises mermaid with securityLevel 'sandbox', which renders
// every diagram inside an iframe. In sandbox mode mermaid sizes that iframe from the
// SVG's *unscaled* viewBox height, while the SVG itself is scaled down to fit the page
// width. Wide diagrams (e.g. sequence diagrams with many participants) therefore render
// small but still reserve their full natural height, leaving a large block of empty
// space beneath the diagram.
//
// 'strict' is mermaid's own default securityLevel. It renders inline SVG instead of an
// iframe, so the height always matches what is drawn. Script execution and click
// handlers remain disabled and label text is still sanitised.
//
// Everything else below is unchanged from the base template.
document.addEventListener('DOMContentLoaded', function() {
  const mermaidCodes = document.querySelectorAll('pre.language-mermaid code.language-mermaid');
  Array.from(mermaidCodes).forEach(function(code) {
    const pre = code.parentNode;
    const content = code.textContent;
    const mermaidDiv = document.createElement('div');
    mermaidDiv.className = 'mermaid';
    mermaidDiv.textContent = content;
    pre.parentNode.replaceChild(mermaidDiv, pre);
  });
  mermaid.initialize({ securityLevel: 'strict' });
});

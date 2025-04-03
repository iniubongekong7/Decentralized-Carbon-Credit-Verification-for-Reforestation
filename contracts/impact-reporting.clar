;; Impact Reporting Contract
;; Tracks environmental benefits of reforestation

(define-map project-impact
  { project-id: uint }
  {
    total-carbon-sequestered: uint,
    biodiversity-score: uint,
    water-impact-score: uint,
    social-impact-score: uint,
    last-updated: uint
  }
)

(define-map impact-reports
  { project-id: uint, report-id: uint }
  {
    reporter: principal,
    report-date: uint,
    carbon-update: uint,
    biodiversity-update: uint,
    water-impact-update: uint,
    social-impact-update: uint,
    notes: (string-utf8 500)
  }
)

(define-map project-report-count
  { project-id: uint }
  { count: uint }
)

(define-constant contract-owner tx-sender)
(define-constant err-not-authorized u1)
(define-constant err-project-not-found u2)

(define-public (initialize-impact (project-id uint))
  (begin
    (map-set project-impact
      { project-id: project-id }
      {
        total-carbon-sequestered: u0,
        biodiversity-score: u0,
        water-impact-score: u0,
        social-impact-score: u0,
        last-updated: block-height
      }
    )
    (ok true)
  )
)

(define-public (add-impact-report
    (project-id uint)
    (carbon-update uint)
    (biodiversity-update uint)
    (water-impact-update uint)
    (social-impact-update uint)
    (notes (string-utf8 500)))
  (let (
    (current-count (default-to { count: u0 } (map-get? project-report-count { project-id: project-id })))
    (new-report-id (+ (get count current-count) u1))
    (current-impact (default-to
      {
        total-carbon-sequestered: u0,
        biodiversity-score: u0,
        water-impact-score: u0,
        social-impact-score: u0,
        last-updated: u0
      }
      (map-get? project-impact { project-id: project-id })))
  )
    ;; Update report count
    (map-set project-report-count
      { project-id: project-id }
      { count: new-report-id }
    )

    ;; Add new report
    (map-set impact-reports
      { project-id: project-id, report-id: new-report-id }
      {
        reporter: tx-sender,
        report-date: block-height,
        carbon-update: carbon-update,
        biodiversity-update: biodiversity-update,
        water-impact-update: water-impact-update,
        social-impact-update: social-impact-update,
        notes: notes
      }
    )

    ;; Update cumulative impact
    (map-set project-impact
      { project-id: project-id }
      {
        total-carbon-sequestered: (+ (get total-carbon-sequestered current-impact) carbon-update),
        biodiversity-score: biodiversity-update,
        water-impact-score: water-impact-update,
        social-impact-score: social-impact-update,
        last-updated: block-height
      }
    )

    (ok new-report-id)
  )
)

(define-read-only (get-project-impact (project-id uint))
  (map-get? project-impact { project-id: project-id })
)

(define-read-only (get-impact-report (project-id uint) (report-id uint))
  (map-get? impact-reports { project-id: project-id, report-id: report-id })
)

(define-read-only (get-report-count (project-id uint))
  (default-to { count: u0 } (map-get? project-report-count { project-id: project-id }))
)

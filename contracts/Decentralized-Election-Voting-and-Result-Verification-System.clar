(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-election-not-active (err u104))
(define-constant err-already-voted (err u105))
(define-constant err-invalid-candidate (err u106))
(define-constant err-election-ended (err u107))
(define-constant err-election-not-ended (err u108))
(define-constant err-proposal-not-found (err u109))
(define-constant err-already-voted-proposal (err u110))

(define-data-var election-counter uint u0)
(define-data-var proposal-counter uint u0)

(define-map elections 
  uint 
  {
    title: (string-ascii 100),
    creator: principal,
    start-block: uint,
    end-block: uint,
    is-active: bool,
    total-votes: uint,
    candidates: (list 10 (string-ascii 50))
  }
)

(define-map election-results
  {election-id: uint, candidate: (string-ascii 50)}
  uint
)

(define-map voter-tokens
  principal
  {
    token-id: uint,
    is-verified: bool,
    elections-voted: (list 20 uint)
  }
)

(define-map election-voters
  {election-id: uint, voter: principal}
  {
    candidate: (string-ascii 50),
    vote-block: uint,
    vote-hash: (buff 32)
  }
)

(define-map proposals
  uint
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    proposer: principal,
    election-id: uint,
    yes-votes: uint,
    no-votes: uint,
    end-block: uint,
    is-active: bool
  }
)

(define-map proposal-votes
  {proposal-id: uint, voter: principal}
  bool
)

(define-public (register-voter)
  (let 
    (
      (current-token-id (+ (var-get election-counter) u1))
    )
    (asserts! (is-none (map-get? voter-tokens tx-sender)) err-already-exists)
    (map-set voter-tokens tx-sender {
      token-id: current-token-id,
      is-verified: true,
      elections-voted: (list)
    })
    (ok current-token-id)
  )
)

(define-public (create-election (title (string-ascii 100)) (candidates (list 10 (string-ascii 50))) (duration uint))
  (let 
    (
      (election-id (+ (var-get election-counter) u1))
      (start-block stacks-block-height)
      (end-block (+ stacks-block-height duration))
    )
    (asserts! (> (len candidates) u0) err-invalid-candidate)
    (asserts! (<= (len candidates) u10) err-invalid-candidate)
    (map-set elections election-id {
      title: title,
      creator: tx-sender,
      start-block: start-block,
      end-block: end-block,
      is-active: true,
      total-votes: u0,
      candidates: candidates
    })
    (var-set election-counter election-id)
    (ok election-id)
  )
)

(define-public (cast-vote (election-id uint) (candidate (string-ascii 50)))
  (let 
    (
      (election (unwrap! (map-get? elections election-id) err-not-found))
      (voter-info (unwrap! (map-get? voter-tokens tx-sender) err-unauthorized))
      (vote-hash (sha256 (concat (concat (unwrap-panic (to-consensus-buff? tx-sender)) (unwrap-panic (to-consensus-buff? election-id))) (unwrap-panic (to-consensus-buff? candidate)))))
    )
    (asserts! (get is-verified voter-info) err-unauthorized)
    (asserts! (get is-active election) err-election-not-active)
    (asserts! (<= stacks-block-height (get end-block election)) err-election-ended)
    (asserts! (is-none (map-get? election-voters {election-id: election-id, voter: tx-sender})) err-already-voted)
    (asserts! (is-some (index-of (get candidates election) candidate)) err-invalid-candidate)
    
    (map-set election-voters {election-id: election-id, voter: tx-sender} {
      candidate: candidate,
      vote-block: stacks-block-height,
      vote-hash: vote-hash
    })
    
    (let 
      (
        (current-votes (default-to u0 (map-get? election-results {election-id: election-id, candidate: candidate})))
        (updated-elections-voted (unwrap-panic (as-max-len? (append (get elections-voted voter-info) election-id) u20)))
      )
      (map-set election-results {election-id: election-id, candidate: candidate} (+ current-votes u1))
      (map-set voter-tokens tx-sender (merge voter-info {elections-voted: updated-elections-voted}))
      (map-set elections election-id (merge election {total-votes: (+ (get total-votes election) u1)}))
      (ok true)
    )
  )
)

(define-public (end-election (election-id uint))
  (let 
    (
      (election (unwrap! (map-get? elections election-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator election)) err-unauthorized)
    (asserts! (> stacks-block-height (get end-block election)) err-election-not-ended)
    (map-set elections election-id (merge election {is-active: false}))
    (ok true)
  )
)

(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (election-id uint) (duration uint))
  (let 
    (
      (proposal-id (+ (var-get proposal-counter) u1))
      (election (unwrap! (map-get? elections election-id) err-not-found))
      (voter-info (unwrap! (map-get? voter-tokens tx-sender) err-unauthorized))
    )
    (asserts! (get is-verified voter-info) err-unauthorized)
    (asserts! (not (get is-active election)) err-election-not-ended)
    (map-set proposals proposal-id {
      title: title,
      description: description,
      proposer: tx-sender,
      election-id: election-id,
      yes-votes: u0,
      no-votes: u0,
      end-block: (+ stacks-block-height duration),
      is-active: true
    })
    (var-set proposal-counter proposal-id)
    (ok proposal-id)
  )
)

(define-public (vote-proposal (proposal-id uint) (vote bool))
  (let 
    (
      (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
      (voter-info (unwrap! (map-get? voter-tokens tx-sender) err-unauthorized))
    )
    (asserts! (get is-verified voter-info) err-unauthorized)
    (asserts! (get is-active proposal) err-election-not-active)
    (asserts! (<= stacks-block-height (get end-block proposal)) err-election-ended)
    (asserts! (is-none (map-get? proposal-votes {proposal-id: proposal-id, voter: tx-sender})) err-already-voted-proposal)
    
    (map-set proposal-votes {proposal-id: proposal-id, voter: tx-sender} vote)
    (if vote
      (map-set proposals proposal-id (merge proposal {yes-votes: (+ (get yes-votes proposal) u1)}))
      (map-set proposals proposal-id (merge proposal {no-votes: (+ (get no-votes proposal) u1)}))
    )
    (ok true)
  )
)

(define-public (finalize-proposal (proposal-id uint))
  (let 
    (
      (proposal (unwrap! (map-get? proposals proposal-id) err-proposal-not-found))
    )
    (asserts! (is-eq tx-sender (get proposer proposal)) err-unauthorized)
    (asserts! (> stacks-block-height (get end-block proposal)) err-election-not-ended)
    (map-set proposals proposal-id (merge proposal {is-active: false}))
    (ok true)
  )
)

(define-read-only (get-election (election-id uint))
  (map-get? elections election-id)
)

(define-read-only (get-election-results (election-id uint) (candidate (string-ascii 50)))
  (default-to u0 (map-get? election-results {election-id: election-id, candidate: candidate}))
)

(define-read-only (get-voter-info (voter principal))
  (map-get? voter-tokens voter)
)

(define-read-only (get-vote-proof (election-id uint) (voter principal))
  (map-get? election-voters {election-id: election-id, voter: voter})
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-vote (proposal-id uint) (voter principal))
  (map-get? proposal-votes {proposal-id: proposal-id, voter: voter})
)

(define-read-only (verify-vote-integrity (election-id uint) (voter principal) (candidate (string-ascii 50)))
  (let 
    (
      (vote-record (map-get? election-voters {election-id: election-id, voter: voter}))
      (expected-hash (sha256 (concat (concat (unwrap-panic (to-consensus-buff? voter)) (unwrap-panic (to-consensus-buff? election-id))) (unwrap-panic (to-consensus-buff? candidate)))))
    )
    (match vote-record
      vote-data (is-eq (get vote-hash vote-data) expected-hash)
      false
    )
  )
)

(define-read-only (get-election-winner (election-id uint))
  (let 
    (
      (election (unwrap! (map-get? elections election-id) err-not-found))
      (candidates (get candidates election))
    )
    (if (get is-active election)
      err-election-not-ended
      (ok (fold find-winner candidates {winner: "", max-votes: u0, election-id: election-id}))
    )
  )
)

(define-private (find-winner (candidate (string-ascii 50)) (acc {winner: (string-ascii 50), max-votes: uint, election-id: uint}))
  (let 
    (
      (votes (get-election-results (get election-id acc) candidate))
    )
    (if (> votes (get max-votes acc))
      {winner: candidate, max-votes: votes, election-id: (get election-id acc)}
      acc
    )
  )
)

;; Global AI Network - Decentralized AI Marketplace
;; A smart contract for registering AI models, managing computation tasks, and distributing rewards

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INVALID_INPUT (err u102))
(define-constant ERR_INSUFFICIENT_BALANCE (err u103))
(define-constant ERR_TASK_NOT_AVAILABLE (err u104))
(define-constant ERR_ALREADY_EXISTS (err u105))
(define-constant ERR_TASK_COMPLETED (err u106))
(define-constant ERR_INVALID_STATUS (err u107))

;; Data Variables
(define-data-var next-model-id uint u1)
(define-data-var next-task-id uint u1)
(define-data-var platform-fee-percent uint u5) ;; 5% platform fee
(define-data-var total-platform-fees uint u0)

;; Data Maps
(define-map ai-models 
    uint 
    {
        owner: principal,
        name: (string-ascii 50),
        description: (string-ascii 200),
        category: (string-ascii 30),
        price-per-computation: uint,
        total-computations: uint,
        reputation-score: uint,
        is-active: bool,
        created-at: uint
    }
)

(define-map computation-tasks
    uint
    {
        requester: principal,
        model-id: uint,
        input-data-hash: (string-ascii 64),
        output-data-hash: (optional (string-ascii 64)),
        reward-amount: uint,
        status: (string-ascii 20), ;; "pending", "assigned", "completed", "disputed"
        assigned-provider: (optional principal),
        created-at: uint,
        completed-at: (optional uint)
    }
)

(define-map user-balances principal uint)
(define-map user-reputation principal uint)
(define-map model-providers principal (list 50 uint)) ;; List of model IDs owned by user

;; Read-only functions
(define-read-only (get-model (model-id uint))
    (map-get? ai-models model-id)
)

(define-read-only (get-task (task-id uint))
    (map-get? computation-tasks task-id)
)

(define-read-only (get-user-balance (user principal))
    (default-to u0 (map-get? user-balances user))
)

(define-read-only (get-user-reputation (user principal))
    (default-to u0 (map-get? user-reputation user))
)

(define-read-only (get-user-models (user principal))
    (default-to (list) (map-get? model-providers user))
)

(define-read-only (get-next-model-id)
    (var-get next-model-id)
)

(define-read-only (get-next-task-id)
    (var-get next-task-id)
)

(define-read-only (get-platform-fee-percent)
    (var-get platform-fee-percent)
)

(define-read-only (get-total-platform-fees)
    (var-get total-platform-fees)
)

;; Private functions
(define-private (calculate-platform-fee (amount uint))
    (/ (* amount (var-get platform-fee-percent)) u100)
)

(define-private (update-user-models (user principal) (model-id uint))
    (let ((current-models (get-user-models user)))
        (map-set model-providers user (unwrap-panic (as-max-len? (append current-models model-id) u50)))
    )
)

;; Public functions

;; Register a new AI model
(define-public (register-ai-model 
    (name (string-ascii 50))
    (description (string-ascii 200))
    (category (string-ascii 30))
    (price-per-computation uint))
    (let ((model-id (var-get next-model-id)))
        (asserts! (> (len name) u0) ERR_INVALID_INPUT)
        (asserts! (> price-per-computation u0) ERR_INVALID_INPUT)
        
        ;; Create model entry
        (map-set ai-models model-id {
            owner: tx-sender,
            name: name,
            description: description,
            category: category,
            price-per-computation: price-per-computation,
            total-computations: u0,
            reputation-score: u100, ;; Start with base reputation
            is-active: true,
            created-at: stacks-block-height
        })
        
        ;; Update user's model list
        (update-user-models tx-sender model-id)
        
        ;; Increment model ID counter
        (var-set next-model-id (+ model-id u1))
        
        (ok model-id)
    )
)

;; Create a computation task
(define-public (create-computation-task 
    (model-id uint)
    (input-data-hash (string-ascii 64))
    (reward-amount uint))
    (let ((task-id (var-get next-task-id))
          (model-info (unwrap! (get-model model-id) ERR_NOT_FOUND))
          (user-balance (get-user-balance tx-sender)))
        
        (asserts! (>= user-balance reward-amount) ERR_INSUFFICIENT_BALANCE)
        (asserts! (get is-active model-info) ERR_TASK_NOT_AVAILABLE)
        (asserts! (>= reward-amount (get price-per-computation model-info)) ERR_INVALID_INPUT)
        
        ;; Deduct reward amount from user balance (escrow)
        (map-set user-balances tx-sender (- user-balance reward-amount))
        
        ;; Create task
        (map-set computation-tasks task-id {
            requester: tx-sender,
            model-id: model-id,
            input-data-hash: input-data-hash,
            output-data-hash: none,
            reward-amount: reward-amount,
            status: "pending",
            assigned-provider: none,
            created-at: stacks-block-height,
            completed-at: none
        })
        
        ;; Increment task ID counter
        (var-set next-task-id (+ task-id u1))
        
        (ok task-id)
    )
)

;; Assign task to provider (model owner)
(define-public (assign-task (task-id uint))
    (let ((task-info (unwrap! (get-task task-id) ERR_NOT_FOUND))
          (model-info (unwrap! (get-model (get model-id task-info)) ERR_NOT_FOUND)))
        
        (asserts! (is-eq tx-sender (get owner model-info)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status task-info) "pending") ERR_INVALID_STATUS)
        
        ;; Update task with assigned provider
        (map-set computation-tasks task-id (merge task-info {
            status: "assigned",
            assigned-provider: (some tx-sender)
        }))
        
        (ok true)
    )
)

;; Complete computation task
(define-public (complete-task 
    (task-id uint)
    (output-data-hash (string-ascii 64)))
    (let ((task-info (unwrap! (get-task task-id) ERR_NOT_FOUND))
          (model-info (unwrap! (get-model (get model-id task-info)) ERR_NOT_FOUND)))
        
        (asserts! (is-eq tx-sender (get owner model-info)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status task-info) "assigned") ERR_INVALID_STATUS)
        (asserts! (is-eq (some tx-sender) (get assigned-provider task-info)) ERR_UNAUTHORIZED)
        
        (let ((reward-amount (get reward-amount task-info))
              (platform-fee (calculate-platform-fee reward-amount))
              (provider-reward (- reward-amount platform-fee))
              (provider-balance (get-user-balance tx-sender))
              (provider-reputation (get-user-reputation tx-sender)))
            
            ;; Update task as completed
            (map-set computation-tasks task-id (merge task-info {
                status: "completed",
                output-data-hash: (some output-data-hash),
                completed-at: (some stacks-block-height)
            }))
            
            ;; Pay provider
            (map-set user-balances tx-sender (+ provider-balance provider-reward))
            
            ;; Update platform fees
            (var-set total-platform-fees (+ (var-get total-platform-fees) platform-fee))
            
            ;; Update provider reputation
            (map-set user-reputation tx-sender (+ provider-reputation u10))
            
            ;; Update model statistics
            (map-set ai-models (get model-id task-info) (merge model-info {
                total-computations: (+ (get total-computations model-info) u1),
                reputation-score: (+ (get reputation-score model-info) u5)
            }))
            
            (ok true)
        )
    )
)

;; Deposit funds to user balance
(define-public (deposit-funds (amount uint))
    (let ((current-balance (get-user-balance tx-sender)))
        (asserts! (> amount u0) ERR_INVALID_INPUT)
        
        ;; In a real implementation, this would involve STX transfer
        ;; For MVP, we simulate deposit
        (map-set user-balances tx-sender (+ current-balance amount))
        
        (ok true)
    )
)

;; Withdraw funds from user balance
(define-public (withdraw-funds (amount uint))
    (let ((current-balance (get-user-balance tx-sender)))
        (asserts! (>= current-balance amount) ERR_INSUFFICIENT_BALANCE)
        (asserts! (> amount u0) ERR_INVALID_INPUT)
        
        ;; Update balance
        (map-set user-balances tx-sender (- current-balance amount))
        
        ;; In a real implementation, this would involve STX transfer
        (ok true)
    )
)

;; Update model status (activate/deactivate)
(define-public (update-model-status (model-id uint) (is-active bool))
    (let ((model-info (unwrap! (get-model model-id) ERR_NOT_FOUND)))
        (asserts! (is-eq tx-sender (get owner model-info)) ERR_UNAUTHORIZED)
        
        (map-set ai-models model-id (merge model-info {
            is-active: is-active
        }))
        
        (ok true)
    )
)

;; Admin function to update platform fee (only contract owner)
(define-public (update-platform-fee (new-fee-percent uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (<= new-fee-percent u20) ERR_INVALID_INPUT) ;; Max 20% fee
        
        (var-set platform-fee-percent new-fee-percent)
        (ok true)
    )
)

;; Admin function to withdraw platform fees (only contract owner)
(define-public (withdraw-platform-fees)
    (let ((total-fees (var-get total-platform-fees)))
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> total-fees u0) ERR_INSUFFICIENT_BALANCE)
        
        (var-set total-platform-fees u0)
        ;; In a real implementation, this would transfer STX to contract owner
        (ok total-fees)
    )
)